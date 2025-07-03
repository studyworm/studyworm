-- UFW0030U 복원 : TBSUFURSF, TBSUFURSS, TBSUFURTS, TBSUWUTNQ, TBSUFUTRR, TBSITUTRE, TBSIAUBIV, TBSIAUEIV, TBSTAUDPM
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFURSF ) of cursor REPLACE into MBSASSTD.TBSUFURSF nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFURSS ) of cursor REPLACE into MBSASSTD.TBSUFURSS nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFURTS ) of cursor REPLACE into MBSASSTD.TBSUFURTS nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUWUTNQ ) of cursor REPLACE into MBSASSTD.TBSUWUTNQ nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFUTRR ) of cursor REPLACE into MBSASSTD.TBSUFUTRR nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSITUTRE ) of cursor REPLACE into MBSASSTD.TBSITUTRE nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSIAUBIV ) of cursor REPLACE into MBSASSTD.TBSIAUBIV nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSIAUEIV ) of cursor REPLACE into MBSASSTD.TBSIAUEIV nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSTAUDPM ) of cursor REPLACE into MBSASSTD.TBSTAUDPM nonrecoverable');


-- UFW0020U 복원
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFURCF ) of cursor REPLACE into MBSASSTD.TBSUFURCF nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFURCS ) of cursor REPLACE into MBSASSTD.TBSUFURCS nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSUFUTRR ) of cursor REPLACE into MBSASSTD.TBSUFUTRR nonrecoverable');

call admin_cmd('load from ( select * from MBSASMDTBAK.TBSIAUWHS ) of cursor REPLACE into MBSASSTD.TBSIAUWHS nonrecoverable');

call admin_cmd('load from /dev/null of del TERMINATE into  MBSASSTD.TBSUFURCF nonrecoverable')


SELECT * FROM MBSASSTD.TBSUFURCF WHERE LST_UPD_DTM > '2023-11-15';