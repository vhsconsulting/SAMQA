-- liquibase formatted sql
-- changeset SAMQA:1754373943656 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_reg_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_reg_type.sql:null:1eeb8cf9ce682079738a7edc45c17f47f2827097:create

grant select on samqa.emp_reg_type to rl_sam1_ro;

grant select on samqa.emp_reg_type to rl_sam_rw;

grant select on samqa.emp_reg_type to rl_sam_ro;

grant select on samqa.emp_reg_type to sgali;

