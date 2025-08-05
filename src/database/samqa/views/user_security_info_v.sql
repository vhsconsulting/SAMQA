create or replace force editionable view samqa.user_security_info_v (
    user_id,
    site_key,
    site_image,
    pw_question1,
    pw_answer1,
    pw_question2,
    pw_answer2,
    pw_question3,
    pw_answer3,
    remember_pc
) as
    select
        user_id,
        site_key,
        site_image,
        pc_user_security_pkg.get_security_question(pw_question1) pw_question1,
        pw_answer1,
        pc_user_security_pkg.get_security_question(pw_question2) pw_question2,
        pw_answer2,
        pc_user_security_pkg.get_security_question(pw_question3) pw_question3,
        pw_answer3,
        remember_pc
    from
        user_security_info;


-- sqlcl_snapshot {"hash":"5ed449cd404292591641ee2b5fbfb5c1a04b708a","type":"VIEW","name":"USER_SECURITY_INFO_V","schemaName":"SAMQA","sxml":""}