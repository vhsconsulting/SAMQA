-- liquibase formatted sql
-- changeset SAMQA:1754374172213 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_reg_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_reg_type.sql:null:70b524022dca725ef80d7d3cf2388983998cc526:create

create or replace force editionable view samqa.emp_reg_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'EMP_REG_TYPE';

