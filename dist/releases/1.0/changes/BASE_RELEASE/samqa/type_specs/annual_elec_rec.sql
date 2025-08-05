-- liquibase formatted sql
-- changeset SAMQA:1754374166276 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\annual_elec_rec.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/annual_elec_rec.sql:null:32ff78f1247ce39ba585fd4d288c0cb487eeffe5:create

create or replace type samqa.annual_elec_rec as object (
        batch_number  number,
        entrp_id      number,
        check_amount  number,
        plan_type     varchar2(255),
        plan_end_date date
);
/

