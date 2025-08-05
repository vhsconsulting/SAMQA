-- liquibase formatted sql
-- changeset SAMQA:1754374178849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\subscriber_for_enterprise.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/subscriber_for_enterprise.sql:null:0d34090605e34b9204e373b7ac5f1668601119a9:create

create or replace force editionable view samqa.subscriber_for_enterprise (
    acc_id,
    pers_id,
    entrp_id,
    entrp_acc_id
) as
    select
        d.acc_id,
        b.pers_id,
        a.entrp_id,
        c.acc_id entrp_acc_id
    from
        enterprise a,
        person     b,
        account    c,
        account    d
    where
            a.entrp_id = c.entrp_id
        and a.entrp_id = b.entrp_id
        and b.pers_id = d.pers_id;

