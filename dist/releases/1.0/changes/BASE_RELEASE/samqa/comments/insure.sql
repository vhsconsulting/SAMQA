-- liquibase formatted sql
-- changeset samqa:1754373926624 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\insure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/insure.sql:null:d8f0a463b618755ab62f389469428a84e5fbe44c:create

comment on table samqa.insure is
    'Subscriber insurance info.';

comment on column samqa.insure.deductible is
    'Current Deductible';

comment on column samqa.insure.group_no is
    'Actualy, Subscriber''s Employer id';

comment on column samqa.insure.insur_id is
    'The insurance company, reference to ENTERPRISE';

comment on column samqa.insure.note is
    'Any useful remarks';

comment on column samqa.insure.op_max is
    'Out-of-pocket maximum.';

comment on column samqa.insure.pers_id is
    'Reference to Subscriber';

comment on column samqa.insure.policy_num is
    'The insurance policy number.';

comment on column samqa.insure.start_date is
    'Enforce date';

