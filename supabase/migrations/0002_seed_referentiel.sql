-- Données de référence : 114 sourates, 60 hizbs, 480 tomons (8 par hizb).
-- Noms des sourates en transcription française courante : à vérifier/ajuster
-- selon la convention déjà utilisée dans l'ancienne application.

insert into public.sourates (id, nom) values
  (1, 'Al-Fatiha'), (2, 'Al-Baqara'), (3, 'Al Imran'), (4, 'An-Nisa'),
  (5, 'Al-Maïda'), (6, 'Al-Anam'), (7, 'Al-Araf'), (8, 'Al-Anfal'),
  (9, 'At-Tawba'), (10, 'Yunus'), (11, 'Hud'), (12, 'Yusuf'),
  (13, 'Ar-Rad'), (14, 'Ibrahim'), (15, 'Al-Hijr'), (16, 'An-Nahl'),
  (17, 'Al-Isra'), (18, 'Al-Kahf'), (19, 'Maryam'), (20, 'Ta-Ha'),
  (21, 'Al-Anbiya'), (22, 'Al-Hajj'), (23, 'Al-Muminun'), (24, 'An-Nur'),
  (25, 'Al-Furqan'), (26, 'Ash-Shuara'), (27, 'An-Naml'), (28, 'Al-Qasas'),
  (29, 'Al-Ankabut'), (30, 'Ar-Rum'), (31, 'Luqman'), (32, 'As-Sajda'),
  (33, 'Al-Ahzab'), (34, 'Saba'), (35, 'Fatir'), (36, 'Ya-Sin'),
  (37, 'As-Saffat'), (38, 'Sad'), (39, 'Az-Zumar'), (40, 'Ghafir'),
  (41, 'Fussilat'), (42, 'Ash-Shura'), (43, 'Az-Zukhruf'), (44, 'Ad-Dukhan'),
  (45, 'Al-Jathiya'), (46, 'Al-Ahqaf'), (47, 'Muhammad'), (48, 'Al-Fath'),
  (49, 'Al-Hujurat'), (50, 'Qaf'), (51, 'Adh-Dhariyat'), (52, 'At-Tur'),
  (53, 'An-Najm'), (54, 'Al-Qamar'), (55, 'Ar-Rahman'), (56, 'Al-Waqia'),
  (57, 'Al-Hadid'), (58, 'Al-Mujadila'), (59, 'Al-Hashr'), (60, 'Al-Mumtahana'),
  (61, 'As-Saff'), (62, 'Al-Jumua'), (63, 'Al-Munafiqun'), (64, 'At-Taghabun'),
  (65, 'At-Talaq'), (66, 'At-Tahrim'), (67, 'Al-Mulk'), (68, 'Al-Qalam'),
  (69, 'Al-Haqqa'), (70, 'Al-Maarij'), (71, 'Nuh'), (72, 'Al-Jinn'),
  (73, 'Al-Muzzammil'), (74, 'Al-Muddaththir'), (75, 'Al-Qiyama'), (76, 'Al-Insan'),
  (77, 'Al-Mursalat'), (78, 'An-Naba'), (79, 'An-Naziat'), (80, 'Abasa'),
  (81, 'At-Takwir'), (82, 'Al-Infitar'), (83, 'Al-Mutaffifin'), (84, 'Al-Inshiqaq'),
  (85, 'Al-Buruj'), (86, 'At-Tariq'), (87, 'Al-Ala'), (88, 'Al-Ghashiya'),
  (89, 'Al-Fajr'), (90, 'Al-Balad'), (91, 'Ash-Shams'), (92, 'Al-Layl'),
  (93, 'Ad-Duha'), (94, 'Ash-Sharh'), (95, 'At-Tin'), (96, 'Al-Alaq'),
  (97, 'Al-Qadr'), (98, 'Al-Bayyina'), (99, 'Az-Zalzala'), (100, 'Al-Adiyat'),
  (101, 'Al-Qaria'), (102, 'At-Takathur'), (103, 'Al-Asr'), (104, 'Al-Humaza'),
  (105, 'Al-Fil'), (106, 'Quraysh'), (107, 'Al-Maun'), (108, 'Al-Kawthar'),
  (109, 'Al-Kafirun'), (110, 'An-Nasr'), (111, 'Al-Masad'), (112, 'Al-Ikhlas'),
  (113, 'Al-Falaq'), (114, 'An-Nas')
on conflict (id) do nothing;

insert into public.hizbs (id)
select generate_series(1, 60)
on conflict (id) do nothing;

insert into public.tomons (id, hizb_id, position_dans_hizb)
select
  n as id,
  ((n - 1) / 8) + 1 as hizb_id,
  ((n - 1) % 8) + 1 as position_dans_hizb
from generate_series(1, 480) as n
on conflict (id) do nothing;

-- La table tomon_sourate (correspondance tomon -> sourate(s), avec la demi-part
-- pour un tomon partagé entre deux sourates) n'est PAS seedée automatiquement :
-- elle doit être reprise depuis les données de l'ancienne application PHP/MySQL,
-- seule source fiable pour cette correspondance fine.
