insert into users            VALUES( 1, 'Marek', 'Julian', 'Ryniejski', NULL, NULL, 'San Francisco', 'CA', 'USA', '94114', 45, 'M', NULL, 'marekjulian', 'marek@marekjulian.com', '917c21164acecde9bfe2f1b492d13e1e89aa1d26', '9b3468ca1877a66a80850a943931c19cb79a7862', '2009-02-23 02:23:42', '2009-03-15 03:23:55', NULL, NULL, 'd51a3e5c26aaa446dd53bc6a98a380962aa24498', '2009-02-23 02:23:42', 'SiteUser', NULL, true, NULL, NULL, NULL, '' );
insert into owners           VALUES( 1, 1 );
insert into archives         VALUES( 1, 1, 'Marek Julian Image Archive', 'Marek Julian Photography Image Archive, porfolio, stock, and client collaboration.', now(), now());
insert into collections      VALUES( 1, 1, 'do I know you?', 'People and portrait portfolio', now(), now() );
insert into collections      VALUES( 2, 1, 'my, you are so beautiful!', 'Beauty portfolio', now(), now() );
insert into images           VALUES( 1, 1, 1, 2, 3, 'woman on concrete' );
insert into image_variants   VALUES( 1, 1, 'EPSN2096_final.psd',         'application/octet-stream', 16593078, true,  false, false, false, now(), now() );
insert into image_variants   VALUES( 2, 1, 'EPSN2096_final_600x400.jpg', 'image/jpeg',               200816,   false, true,  false, false, now(), now() );
insert into image_variants   VALUES( 3, 1, 'EPSN2096_final_60x60.jpg',   'image/jpeg',               38808,    false, false, true,  true,  now(), now() );
insert into images           VALUES( 2, 1, 4, 5, 6, 'woman with stool' );
insert into image_variants   VALUES( 4, 2, '20071125_00077_final.tif',   'image/tiff',               64052848, true, false, false, false, now(), now() );
insert into image_variants   VALUES( 5, 2, '20071125_00077_500x400.jpg', 'image/jpeg',               104300,   false, true, false, false, now(), now() );
insert into image_variants   VALUES( 6, 2, '20071125_00077_60x60.jpg',   'image/jpeg',               40032,    false, false, true, true,  now(), now() );
insert into collections_images     VALUES( 1, 1 );
insert into collections_images     VALUES( 2, 2 );
insert into portfolios       VALUES( 1, 1, 'Marek Julian Photography', 1, now(), now() );
insert into image_show_views       VALUES( 1, 1, 1, 2, 3, 0 );
insert into image_show_views       VALUES( 2, 2, 2, 5, 6, 0 );
insert into portfolio_collections  VALUES( 1, 1, 1, 1, 0 );
insert into portfolio_collections  VALUES( 2, 1, 2, 2, 1 );
