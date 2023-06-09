# KP projektna

## Network definitions

### PUBLIC
- ipv4 = 88.200.24.236/24, ipv6 = 2001:1470:fffd:94::2
- **eth0** interface

### INTERNAL
- ipv4 = 192.168.6.0/24
- **eth2** interface

### DMZ
- ipv4 = 10.6.0.0/24
- **eth1** interface

### IPV6only
- ipv6 = 2001:1470:fffd:94:x:/64
- **eth3** interface

## TODO LIST

- [x] uporabniki in strežniki morajo biti vsak v svojem segmentu.
- [x] "opcijsko" uporabiti morate heterogene operacijske sisteme (vsaj po en Windows, Linux)
- [x] segment "uporabniki" naj ima omrežje 10.X.0.0/24 in segment "strežniki" naj ima omrežje 192.168.X.0/24 (pri čemer je X=številka vaše skupine). Vaš ISP (LRK :)) vam je dodelil eno "zunanjo" IP številko in IPv6 naslovni prostor.
- [x] V omrežju imejte tudi en segment, ki bo uporabljal samo IPv6 protokol (ipv6only). V njem uporabite privatne IPv6 naslove (unique local address - ULA), in jih s tehniko NPTv6 (IPv6-to-IPv6 Network Prefix Translation - RFC 6296) preslikajte v enega izmed vam dodeljenih zunanjih IPv6 segmentov, ki ga še niste uporabili kje drugje (dodeljeni /62 je razdeljen na 4x /64, prvi je za povezavo z internetom, dva za dual stack omrežji DMZ in internal, zadnji pa za NPTv6 ipv6-only segment. NPTv6 je v Vyosu podprt v verziji VyOS >=1.2.
- [x] Nastavite ostale pomembne parametre: DNS, domensko ime, NTP strežnike, ... (torej vse "splošne" nastavitve, ki jih potrebujete v podjetju). Uredite DNS posredovanje in split DNS konfiguracijo (en ("zunanji") DNS za zunanje naslove, če pa pride zahteva znotraj omrežja, ga preusmerite v notranji (split) DNS strežnik, ki vrača notranje privatne IP naslove strežnikov v DMZ.
- [x] Smiselno nastavite storitvi DHCP in NAT. Strežniki naj imajo vedno enako IP številko, vendar mora vseeno biti dodeljena preko DHCP-ja. Uporabniki morajo imet dostop do interneta. Izpostaviti morate tudi nekaj storitev na vaših strežnikih (npr REST, Grafana, Cacti, ntop, ... glejte spodaj).
- [x] Nastavite tudi IPv6, segmentirajte ga sami, pri tem uporabite dodeljen naslovni prostor IPv6. Storitve, ki jih boste nudili uporabnikom izven vašega podjetja, morajo biti dostopne tudi preko IPv6 (kjer je to smiselno). IPv6 nastavite:
- [x] na VyOS statično
- [x] "vsaj" na enemu segmentu z uporabo SLAAC
- [x] "vsaj" na enem segmentu z uporabo DHCPv6
- [x] Sprogramirajte eno REST storitev, kakšne vire (resources) boste izpostavili vašim uporabnikom se lahko odločite sami. Vira naj bosta vsaj dva, med seboj vsaj nekoliko povezana (npr. torej podobno kot je bilo predstavljeno na vajah za stranke in naročila).
- [x] viri naj podpirajo tehnike pogajanja o vsebini (content negotiation), podpreti morate vsaj tri formate (XML, JSON in enega poljubnega - html, text, itd.). 
- [x] "opcijsko" Vsaj ena operacija nad podatki naj bo zaščitena, torej dostopna samo izbrani skupini uporabnikov, ki so vpisani v enem od LDAP strežnikov. Razmislite, katere operacije bodo "prosto" dostopne, katere pa so takšne, da jih lahko uporabljajo le avtenticirani in avtorizirani uporabniki.
- [x] povezave do vaših REST storitev naj bodo varne
- [x] "opcijsko" Storitve naj bodo povezane s podatkovno bazo, tako da se vsebina ohrani tudi ob ponovnem zagonu strežnika
- [0] Storitve naj bodo dostopne poleg HTTP1.1 tudi preko HTTP/2
- [-] "opcijsko" HTTP/3
- [0] "opcijsko" enako naredite tudi v GraphQL
- [x] Postavite imenik uporabnikov (lahko AD - Microsoft Active Directory, lahko pa uporabite tudi kakšen drug LDAP strežnik!), vpišite par testnih uporabnikov, ki jih boste potem uporabljali v ostalih delih vašega sistema (VPN, avtentikacija za REST storitve, ...).
- [-] Smiselno postavite požarne zidove. Razmislite (in dokumentirajte!), kakšna naj bodo pravila znotraj vašega omrežja, kakšna za dostop od zunaj in kakšna za izhodni promet, katere storitve boste izpostavili navzven, katere bodo samo notranje dostopne, katere bodo uporabljale vaše stranke, katere pa administratorji sistema... Ne pozabite, da je vaše omrežje IPv4 in IPv6 (t.i. dual stack)
- [0] Omrežje mora omogočati oddaljen dostop uporabnikov preko navideznih zasebnih omrežij (VPN dostop do vašega omrežja). Pazite na to, da bo VPN dostop varen.
- [x] "Opcijsko" Avtentikacija naj se izvaja na vaš aktivni imenik (ali LDAP kot je OpenLDAP). Torej za tiste uporabnike, ki so vpisani v vašem AD strežniku, oz. imajo v njem celo shranjena digitalna potrdila.
- [x] Upravljanje in nadzor omrežja in storitev:
- [x] Skonfigurirajte SNMP za beleženje dogodkov (beleženje vsaj enega vira, npr. spletnega ali aplikacijskega strežnika, procesorja, pomnilnika ... Poskusite najti nekaj smiselnega za vaš primer postavitve), podatki naj bodo vidni grafično (Cacti, Prometheus+Grafana, ali kar koli drugega...), zato nastavite ustrezno kratke intervale za SNMP pooling (da se bo na zagovoru sploh kaj videlo na grafih). 
- [-] "opcija" Nastavite netflow ali sflow beleženje tokov, generirajte nekaj prometa, ki naj se nato vidi v analizatorju tokov. Integrirate lahko v Cacti (uporabljali ste ga najbrž zgoraj za SNMP - tu morate instalirati vtičnik - plugin) ali pa uporabite kakšen drug programček, npr. "ntop" (ki ima že vgrajeno podporo) in je to ločena storitev za administratorja vašega omrežja.
- [-] "opcija" IDS/IPS: namestite in demostrirajte uporabo IDS/IPS z npr. skeniranjem vašega omrežja z orodjem nmap, uganjevanjem SSH gesla, itd. Uporabite lahko katerokoli odprtokodno rešitev iz tega segmenta, npr. Snort + Snorby, itd.
- [x] RAFT: postavite v vašem podjetju primer storitve, ki uporablja protokol RAFT, na vsaj 3 računalnikih. Lahko je karkoli, kar uporablja RAFT, npr. etcd ali kaj podobnega.



## RAFT 

```bash
cd RAFT && docker-compose up -d
docker network inspect bridge
```

### Join node
```bash
curl --location --request POST 'localhost:2221/raft/join' \
--header 'Content-Type: application/json' \
--data-raw '{
	"node_id": "node_2", 
	"raft_address": "172.17.0.1:1112"
}'
```

### Check status
```bash
curl localhost:2221/raft/stats
```

### Get the key
```bash
curl --location --request GET localhost:2221/store/tilen
```

### Set the key
```bash
curl --location --request POST 'localhost:2221/store' --header 'Content-Type: application/json' --data-raw '{
        "key": "tilen",
        "value": "ozbot"
}'
```
