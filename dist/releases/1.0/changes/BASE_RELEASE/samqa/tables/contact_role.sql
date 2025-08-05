-- liquibase formatted sql
-- changeset SAMQA:1754374154154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\contact_role.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/contact_role.sql:null:017c5aa057ce3bd27459cae9fb3435aa85c9b862:create

create table samqa.contact_role (
    contact_role_id    number,
    contact_id         number,
    role_type          varchar2(255 byte),
    account_type       varchar2(255 byte),
    description        varchar2(255 byte),
    effective_date     date,
    creation_date      date default sysdate,
    created_by         number,
    last_update_date   date default sysdate,
    last_updated_by    number,
    cobra_id_number    number,
    effective_end_date date,
    ref_contact_id     number
);

alter table samqa.contact_role add primary key ( contact_role_id )
    using index enable;

