#!/usr/bin/env python3
"""Sorunlu E-kodlarına çok dilli isim takma adları (aliases) ekler.

Etiketler katkıları her zaman E-koduyla yazmaz ("polysorbate 80",
"stéarate de magnésium", "gomme-laque"...). Bu betik, herhangi bir profilde
halal olmayan kodlara TR/EN/DE/FR/AR/ID isimlerini ekler; kural motoru bu
isimleri metinde bulursa ilgili E-kod girdisinin profil-bazlı hükmünü uygular.

Zaten içindekiler sözlüğünde (ingredients_v0.json) kapsanan kodlara alias
eklenmez (çift bulgu olmasın): E120 karmin, E428/E441 jelatin, E471/E472a-f
mono-digliseritler (alt-dize eşleşmesi), E920 sistein, E1510 etanol.

Çalıştırma: python3 data/add_aliases.py  (repo kökünden)
"""
import json

# code -> (aliases, alias_exceptions)
ALIASES = {
    "E153": (["charbon végétal", "vegetable carbon", "bitkisel karbon",
              "pflanzenkohle", "karbon nabati", "فحم نباتي"], []),
    "E160a": (["carotène", "carotènes", "carotene", "carotenes", "karoten",
               "carotin", "beta-carotin", "karotenoid", "كاروتين"], []),
    "E160c": (["extrait de paprika", "capsanthine", "paprika extract",
               "capsanthin", "kapsantin", "paprika ekstresi",
               "paprikaextrakt", "ekstrak paprika"], []),
    "E160d": (["lycopène", "lycopene", "likopen", "lycopin", "likopen"], []),
    "E160e": (["apocaroténal", "apocarotenal", "apokarotenal"], []),
    "E161b": (["lutéine", "lutein", "lutein"], []),
    "E161g": (["canthaxanthine", "canthaxanthin", "kantaksantin"], []),
    "E304": (["palmitate d'ascorbyle", "ascorbyl palmitate",
              "askorbil palmitat", "ascorbylpalmitat",
              "askorbil palmitat"], []),
    "E334": (["acide tartrique", "tartaric acid", "tartarik asit",
              "weinsäure", "asam tartrat", "حمض الطرطريك"], []),
    "E335": (["tartrate de sodium", "sodium tartrate", "sodyum tartarat",
              "natriumtartrat"], []),
    "E336": (["tartrate de potassium", "crème de tartre",
              "potassium tartrate", "cream of tartar", "potasyum tartarat",
              "kaliumtartrat", "krem tartar"], []),
    "E337": (["tartrate double de sodium et de potassium",
              "sodium potassium tartrate", "sel de seignette",
              "rochelle salt"], []),
    "E353": (["acide métatartrique", "metatartaric acid",
              "metatartarik asit"], []),
    "E354": (["tartrate de calcium", "calcium tartrate",
              "kalsiyum tartarat", "calciumtartrat"], []),
    "E422": (["glycérol", "glycérine", "glycerol", "glycerin", "glycerine",
              "gliserin", "gliserol", "جلسرين", "غليسيرين"],
             ["glycérine végétale", "vegetable glycerin",
              "vegetable glycerine", "plant-based glycerin",
              "bitkisel gliserin", "pflanzliches glycerin",
              "gliserin nabati", "جلسرين نباتي"]),
    "E430": (["stéarate de polyoxyéthylène", "polyoxyethylene stearate"], []),
    "E432": (["polysorbate 20", "tween 20", "polisorbat 20"], []),
    "E433": (["polysorbate 80", "tween 80", "polisorbat 80",
              "بوليسوربات 80"], []),
    "E434": (["polysorbate 40", "tween 40", "polisorbat 40"], []),
    "E435": (["polysorbate 60", "tween 60", "polisorbat 60",
              "بوليسوربات 60"], []),
    "E436": (["polysorbate 65", "tween 65", "polisorbat 65"], []),
    "E445": (["esters glycériques de résine de bois",
              "glycerol esters of wood rosin"], []),
    "E470a": (["sels d'acides gras", "salts of fatty acids",
               "yağ asitlerinin tuzları"], []),
    "E470b": (["sels de magnésium d'acides gras",
               "magnesium salts of fatty acids"], []),
    "E472e": (["datem"], []),
    "E473": (["sucroesters", "esters de saccharose d'acides gras",
              "sucrose esters", "sukroz esterleri", "zuckerester",
              "ester sukrosa"], []),
    "E474": (["sucroglycérides", "sucroglycerides", "sukrogliserit"], []),
    "E475": (["esters polyglycériques d'acides gras",
              "polyglycerol esters", "poligliserol esterleri"], []),
    "E476": (["polyricinoléate de polyglycérol", "pgpr",
              "polyglycerol polyricinoleate",
              "poligliserol polirisinoleat"], []),
    "E477": (["esters de propylène glycol d'acides gras",
              "propylene glycol esters"], []),
    "E481": (["stéaroyl-2-lactylate de sodium",
              "stéaroyl lactylate de sodium", "sodium stearoyl lactylate",
              "sodyum stearoil laktilat", "natriumstearoyllactylat"], []),
    "E482": (["stéaroyl-2-lactylate de calcium",
              "calcium stearoyl lactylate",
              "kalsiyum stearoil laktilat"], []),
    "E483": (["tartrate de stéaryle", "stearyl tartrate"], []),
    "E491": (["monostéarate de sorbitane", "sorbitan monostearate",
              "sorbitan monostearat"], []),
    "E492": (["tristéarate de sorbitane", "sorbitan tristearate",
              "sorbitan tristearat"], []),
    "E493": (["monolaurate de sorbitane", "sorbitan monolaurate"], []),
    "E494": (["monooléate de sorbitane", "sorbitan monooleate"], []),
    "E495": (["monopalmitate de sorbitane", "sorbitan monopalmitate"], []),
    "E542": (["phosphate d'os", "bone phosphate", "kemik fosfatı",
              "knochenphosphat", "فوسفات العظام"], []),
    "E572": (["stéarate de magnésium", "magnesium stearate",
              "magnezyum stearat", "magnesiumstearat",
              "magnesium stearat", "ستيرات المغنيسيوم"], []),
    "E626": (["acide guanylique", "guanylic acid", "guanilik asit"], []),
    "E627": (["guanylate disodique", "disodium guanylate",
              "disodyum guanilat", "dinatriumguanylat",
              "dinatrium guanilat"], []),
    "E628": (["guanylate dipotassique", "dipotassium guanylate"], []),
    "E629": (["guanylate de calcium", "calcium guanylate"], []),
    "E630": (["acide inosinique", "inosinic acid", "inosinik asit"], []),
    "E631": (["inosinate disodique", "disodium inosinate",
              "disodyum inosinat", "dinatriuminosinat",
              "dinatrium inosinat"], []),
    "E632": (["inosinate dipotassique", "dipotassium inosinate"], []),
    "E633": (["inosinate de calcium", "calcium inosinate"], []),
    "E634": (["ribonucléotides de calcium", "calcium ribonucleotides"], []),
    "E635": (["ribonucléotides disodiques", "ribonucléotides",
              "disodium ribonucleotides", "disodyum ribonükleotit",
              "ribonukleotida"], []),
    "E640": (["glycine", "glisin", "glizin"], []),
    "E904": (["gomme-laque", "gomme laque", "shellac", "şellak",
              "schellack", "lak", "شيلاك"], []),
    "E966": (["lactitol", "laktitol"], []),
    "E1100": (["amylase", "amilaz", "amilase"], []),
    "E1518": (["triacétine", "triacetin", "triasetin"], []),
}


def apply(path: str) -> None:
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    by_code = {c["code"]: c for c in d["codes"]}
    missing = [k for k in ALIASES if k not in by_code]
    if missing:
        raise SystemExit(f"{path}: tabloda olmayan kod(lar): {missing}")
    for code, (aliases, exceptions) in ALIASES.items():
        entry = by_code[code]
        # tekrarları at, sırayı koru
        entry["aliases"] = list(dict.fromkeys(a.lower() for a in aliases))
        if exceptions:
            entry["alias_exceptions"] = [e.lower() for e in exceptions]
    d["version"] = "0.3.0"
    d["updated"] = "2026-08-08"
    with open(path, "w", encoding="utf-8") as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"{path}: {len(ALIASES)} koda alias eklendi (v{d['version']})")


if __name__ == "__main__":
    apply("data/e_codes_v0.json")
    apply("app/assets/data/e_codes_v0.json")
