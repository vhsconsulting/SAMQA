-- liquibase formatted sql
-- changeset samqa:1754373926654 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\opportunity.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/opportunity.sql:null:b0e72afe3f3867e8f4781dbbd17ef36d68f585c0:create

comment on column samqa.opportunity.status is
    'A=Active; I=Inactive';

