-- liquibase formatted sql
-- changeset SAMQA:1754374166283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\annual_elec_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/annual_elec_table.sql:null:7f039fa278a745c1f3a309f1f8bbc7dc582ae776:create

create or replace type samqa.annual_elec_table as
    table of annual_elec_rec;
/

