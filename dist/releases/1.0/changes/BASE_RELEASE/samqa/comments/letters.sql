-- liquibase formatted sql
-- changeset samqa:1754373926650 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\letters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/letters.sql:null:f33b12ddebb5362e6d71f69c0d0c23e6cc7f3ce1:create

comment on table samqa.letters is
    'We sent to person. May be, remind to pay monthly';

comment on column samqa.letters.about is
    'Subject, in short';

comment on column samqa.letters.note is
    'Text';

comment on column samqa.letters.pers_id is
    'To whom';

comment on column samqa.letters.send_date is
    'When';

