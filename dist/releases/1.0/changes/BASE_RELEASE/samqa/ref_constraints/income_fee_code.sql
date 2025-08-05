-- liquibase formatted sql
-- changeset SAMQA:1754374147054 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\income_fee_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/income_fee_code.sql:null:02d1df76a2b421b6dee04a2ddf18d19e47c04ee9:create

alter table samqa.income
    add constraint income_fee_code
        foreign key ( fee_code )
            references samqa.fee_names ( fee_code )
        enable;

