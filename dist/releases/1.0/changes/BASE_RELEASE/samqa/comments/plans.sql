-- liquibase formatted sql
-- changeset samqa:1754373926765 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/plans.sql:null:4c7ebc828c877405fb7d50c893bbd3f8c140416d:create

comment on table samqa.plans is
    'Code table for Sterling HSA Fee Schedule';

comment on column samqa.plans.plan_code is
    'For references only';

comment on column samqa.plans.plan_name is
    'Name of plan';

comment on column samqa.plans.plan_sign is
    'One character (letter)for plan';

