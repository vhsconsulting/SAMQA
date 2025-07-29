create or replace force editionable view samqa.sam_login_summary_v (
    apex_user,
    no_of_hours_in_sam,
    first_login,
    last_login
) as
    select
        apex_user,
        no_of_hours_in_sam,
        to_char(
            decode(first_login,
                   100,
                   last_login,
                   trunc(sysdate) +(first_login / 24)),
            'MM/DD/YYYY HH:MI:SS AM'
        )                                             first_login,
        to_char(last_login, 'MM/DD/YYYY HH:MI:SS AM') last_login
    from
        (
            select
                apex_user,
                decode(today_hh01, 0, 0, 1) + decode(today_hh02, 0, 0, 1) + decode(today_hh03, 0, 0, 1) + decode(today_hh04, 0, 0, 1)
                + decode(today_hh05, 0, 0, 1) + decode(today_hh06, 0, 0, 1) + decode(today_hh07, 0, 0, 1) + decode(today_hh08, 0, 0, 1
                ) + decode(today_hh09, 0, 0, 1) + decode(today_hh10, 0, 0, 1) + decode(today_hh11, 0, 0, 1) + decode(today_hh12, 0, 0
                , 1) + decode(today_hh13, 0, 0, 1) + decode(today_hh14, 0, 0, 1) + decode(today_hh15, 0, 0, 1) + decode(today_hh16, 0
                , 0, 1) + decode(today_hh17, 0, 0, 1) + decode(today_hh18, 0, 0, 1) + decode(today_hh19, 0, 0, 1) + decode(today_hh20
                , 0, 0, 1) + decode(today_hh21, 0, 0, 1) + decode(today_hh22, 0, 0, 1) + decode(today_hh23, 0, 0, 1) + decode(today_hh14
                , 0, 0, 1) no_of_hours_in_sam,
                least(
                    decode(today_hh01, 0, 100, 1),
                    decode(today_hh02, 0, 100, 2),
                    decode(today_hh03, 0, 100, 3),
                    decode(today_hh04, 0, 100, 4),
                    decode(today_hh05, 0, 100, 5),
                    decode(today_hh06, 0, 100, 6),
                    decode(today_hh07, 0, 100, 7),
                    decode(today_hh08, 0, 100, 8),
                    decode(today_hh09, 0, 100, 9),
                    decode(today_hh10, 0, 100, 10),
                    decode(today_hh11, 0, 100, 11),
                    decode(today_hh12, 0, 100, 12),
                    decode(today_hh13, 0, 100, 13),
                    decode(today_hh14, 0, 100, 14),
                    decode(today_hh15, 0, 100, 15),
                    decode(today_hh16, 0, 100, 16),
                    decode(today_hh17, 0, 100, 17),
                    decode(today_hh18, 0, 100, 18),
                    decode(today_hh19, 0, 100, 19),
                    decode(today_hh20, 0, 100, 20),
                    decode(today_hh21, 0, 100, 21),
                    decode(today_hh22, 0, 100, 22),
                    decode(today_hh23, 0, 100, 23),
                    decode(today_hh14, 0, 100, 24)
                )                                                                                                                                         first_login
                ,
                last_view                                                                                                                                 last_login
            from
                apex_workspace_log_summary_usr
            where
                apex_user not in ( 'nobody', 'STERLING' )
            order by
                1
        );


-- sqlcl_snapshot {"hash":"61dcd7bcb3befa664de06c1b32cf6e31dc3a44d2","type":"VIEW","name":"SAM_LOGIN_SUMMARY_V","schemaName":"SAMQA","sxml":""}