-- liquibase formatted sql
-- changeset SAMQA:1754373943384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_employer_balance_sam.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_employer_balance_sam.sql:null:7efd559bcac12c9789e35758154a3cb9b364e96e:create

grant select on samqa.cobra_employer_balance_sam to rl_sam_ro;

