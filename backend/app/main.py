"""Halis backend — etiket normalizasyon servisi.

Görev bölüşümü (docs/03-mvp-plani.md):
  * Uygulama, etiket fotoğrafını cihaz üstünde OCR'lar (ML Kit, ücretsiz) ve
    ham metni buraya gönderir — görüntü değil metin gelir (ucuz + mahrem).
  * Bu servis LLM ile metni normalize eder: içerik listesi, E-kodları ve
    şüpheli terimleri AYIKLAR. Hüküm VERMEZ.
  * Helal/haram kararı daima uygulamadaki yerel kural motorundadır; LLM
    çıktısı tek başına asla "yeşil" yakamaz (docs/03, risk #1).
"""

import os
from typing import List, Optional

import anthropic
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

# Maliyet planı (docs/02): Haiku 4.5 varsayılan; A/B için env ile değiştirilebilir.
MODEL = os.environ.get("HALIS_MODEL", "claude-haiku-4-5")
FREE_MONTHLY_QUOTA = int(os.environ.get("HALIS_FREE_QUOTA", "10"))

app = FastAPI(title="Halis API", version="0.1.0")
client = anthropic.Anthropic()  # ANTHROPIC_API_KEY ortamdan


class NormalizeRequest(BaseModel):
    text: str = Field(..., min_length=3, max_length=8000, description="OCR'dan gelen ham etiket metni")
    lang: Optional[str] = Field(None, description="Etiket dili ipucu (tr/en/de/fr...)")


class NormalizedLabel(BaseModel):
    """LLM'in üreteceği yapılandırılmış çıktı — hüküm içermez."""

    ingredients: List[str] = Field(description="Normalize edilmiş içerik maddeleri, etiketteki sırayla")
    e_codes: List[str] = Field(description="Tespit edilen E-kodları, 'E471' formatında")
    animal_derived_terms: List[str] = Field(
        description="Hayvansal veya hayvansal olabilecek terimler (jelatin, rennet, karmin, mono-digliserit vb.) — etiketteki orijinal yazımıyla"
    )
    alcohol_terms: List[str] = Field(description="Alkol/içki ile ilişkili terimler, orijinal yazımıyla")
    ocr_quality: str = Field(description="'good' | 'partial' | 'poor' — metnin okunabilirlik değerlendirmesi")


SYSTEM_PROMPT = """Sen bir gıda etiketi ayrıştırıcısısın. Sana OCR'dan gelen, hatalı karakterler içerebilen ham bir içindekiler listesi verilir.

Görevin YALNIZCA ayıklamaktır:
1. İçerik maddelerini normalize et (OCR hatalarını düzelt, orijinal dili koru).
2. E-kodlarını standart formata çevir (ör. "E- 471", "e471" → "E471").
3. Hayvansal veya kaynağı hayvansal olabilecek terimleri listele.
4. Alkol/içki ile ilişkili terimleri listele.

ASLA helal/haram hükmü verme. Dini değerlendirme yapma. Sadece metinde GERÇEKTEN geçen ifadeleri raporla; metinde olmayan hiçbir maddeyi ekleme. Emin olamadığın bozuk kelimeleri atlamak yerine en yakın makul okumaya düzelt ve ocr_quality alanında belirt."""


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "model": MODEL}


@app.post("/v1/normalize-label", response_model=NormalizedLabel)
def normalize_label(req: NormalizeRequest) -> NormalizedLabel:
    # TODO: abonelik/kota doğrulama (RevenueCat webhook + cihaz kimliği) buraya
    # gelecek; MVP iskeletinde açık uç bırakıldı.
    try:
        response = client.messages.parse(
            model=MODEL,
            max_tokens=1024,
            system=[
                {
                    "type": "text",
                    "text": SYSTEM_PROMPT,
                    # Sabit sistem istemi önbelleğe alınır; Haiku 4.5'te minimum
                    # önbellek eşiği 4096 token olduğundan kısa istemde etkisizdir,
                    # E-kod tablosu isteme taşınırsa devreye girer.
                    "cache_control": {"type": "ephemeral"},
                }
            ],
            messages=[
                {
                    "role": "user",
                    "content": f"Etiket dili ipucu: {req.lang or 'bilinmiyor'}\n\nHam etiket metni:\n{req.text}",
                }
            ],
            output_format=NormalizedLabel,
        )
    except anthropic.RateLimitError:
        raise HTTPException(status_code=429, detail="Sistem yoğun, lütfen tekrar deneyin.")
    except anthropic.APIStatusError as e:
        raise HTTPException(status_code=502, detail=f"Analiz servisi hatası: {e.status_code}")
    except anthropic.APIConnectionError:
        raise HTTPException(status_code=503, detail="Analiz servisine ulaşılamıyor.")

    if response.parsed_output is None:
        raise HTTPException(status_code=502, detail="Analiz sonucu çözümlenemedi.")
    return response.parsed_output
