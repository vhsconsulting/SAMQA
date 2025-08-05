-- liquibase formatted sql
-- changeset SAMQA:1754374180149 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\user_security_info_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/user_security_info_v.sql:null:5ed449cd404292591641ee2b5fbfb5c1a04b708a:create

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

