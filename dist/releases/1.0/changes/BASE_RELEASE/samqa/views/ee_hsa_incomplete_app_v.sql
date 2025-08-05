-- liquibase formatted sql
-- changeset SAMQA:1754374171779 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ee_hsa_incomplete_app_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ee_hsa_incomplete_app_v.sql:null:c1ade71a0b5570c7db9f41cdbe0668521ad81a02:create

create or replace force editionable view samqa.ee_hsa_incomplete_app_v (
    enrollment_id,
    name,
    email,
    user_name,
    registered,
    acc_num,
    confirmed,
    account_type,
    employer_name,
    reg_date,
    acc_id
) as
    select
        a.enrollment_id,
        a.first_name
        || ' '
        || a.last_name                                        name,
        a.email,
        pc_users.get_user_name(pc_users.get_user(a.ssn, 'S')) user_name,
        pc_users.check_user_registered(a.ssn, 'S')            registered,
        a.acc_num,
        decode(user_name,
               null,
               pc_users.is_confirmed(a.ssn, 'S'),
               'N')                                           confirmed,
        decode(
            substr(a.acc_num, 1, 3),
            'HRA',
            'HRA',
            'FSA',
            'FSA',
            'HSA'
        )                                                     account_type,
        pc_entrp.get_entrp_name(a.entrp_id)                   employer_name,
        b.reg_date,
        b.acc_id
    from
        online_enrollment a,
        account           b
    where
        a.acc_id is not null
        and a.acc_num is not null
        and a.enrollment_status = 'S'
        and a.acc_num = b.acc_num
        and b.complete_flag = 0
        and b.account_status = 3
        and b.signature_on_file = 'N'
        and trunc(b.creation_date) = trunc(sysdate - 5)
        and b.account_type = 'HSA';

