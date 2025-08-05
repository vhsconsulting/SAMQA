-- liquibase formatted sql
-- changeset samqa:1754373926575 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\employer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/employer.sql:null:522b199b40a6e5c413023ad4ed29e53592222da1:create

comment on table samqa.employer is
    'Employers, tail for table ENTERPRISE';

comment on column samqa.employer.cnt is
    'Number of  Subscribers';

comment on column samqa.employer.entrp_id is
    'Reference to ENTERPRISE ID';

comment on column samqa.employer.month_pay is
    'Monthly contribution';

comment on column samqa.employer.note is
    'Any useful remarks';

comment on column samqa.employer.pay_code is
    'Methods of payment, see PAY_TYPE';

comment on column samqa.employer.pay_period is
    'Monthly, Quarterly, Annually...';

