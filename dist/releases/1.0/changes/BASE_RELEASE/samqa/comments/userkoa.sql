-- liquibase formatted sql
-- changeset samqa:1754373926792 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\userkoa.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/userkoa.sql:null:a4831b95341ac1a9fd3124ac2d2066ba4becc31b:create

comment on table samqa.userkoa is
    'List of Oracle users for KOA';

comment on column samqa.userkoa.note is
    'Any useful remarks';

comment on column samqa.userkoa.pers_id is
    'Reference to Person, if we want additional info about this user';

comment on column samqa.userkoa.pers_name is
    'Person name';

comment on column samqa.userkoa.pwd is
    'Oracle user password';

comment on column samqa.userkoa.uname is
    'Oracle user name';

