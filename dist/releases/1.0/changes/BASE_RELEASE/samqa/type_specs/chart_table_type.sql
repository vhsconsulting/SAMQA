-- liquibase formatted sql
-- changeset SAMQA:1754374166291 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\chart_table_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/chart_table_type.sql:null:af838ca187830360e98b82f55668643b9f9e24a4:create

create or replace type samqa.chart_table_type as
    table of varchar2(200);
/

