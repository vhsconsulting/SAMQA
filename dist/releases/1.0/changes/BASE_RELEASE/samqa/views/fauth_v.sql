-- liquibase formatted sql
-- changeset SAMQA:1754374173515 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fauth_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fauth_v.sql:null:6131d9a1d5200c0edef3f498b5813f9cf6ffeba7:create

create or replace force editionable view samqa.fauth_v (
    amount,
    swipe_time,
    description,
    pers_id,
    acc_id,
    log_id
) as
    select
        f.amount                                  amount,
        to_date(f.swipe_time, 'mm/dd/yy hh24:mi') swipe_time,
        f.description                             description,
        p.pers_id                                 pers_id,
        a.acc_id                                  acc_id,
        f.log_id                                  log_id
    from
        fauth   f,
        person  p,
        account a
    where
            f.ssn = p.ssn
        and p.pers_id = a.pers_id;

