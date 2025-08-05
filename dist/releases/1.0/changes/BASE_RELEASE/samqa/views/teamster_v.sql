-- liquibase formatted sql
-- changeset SAMQA:1754374179448 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\teamster_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/teamster_v.sql:null:587b050396f3e05353bba7c0136e4d92993150d7:create

create or replace force editionable view samqa.teamster_v (
    acc_num,
    acc_id,
    entrp_id,
    fee_setup,
    fee_maint
) as
    select
        a.acc_num,
        a.acc_id,
        a.entrp_id,
        fee_setup,
        fee_maint
    from
        account            a,
        account_preference b
    where
            a.acc_id = b.acc_id
        and b.teamster_group = 'Y'
    order by
        1;

