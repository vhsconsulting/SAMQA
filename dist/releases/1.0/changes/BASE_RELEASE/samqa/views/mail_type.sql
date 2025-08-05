-- liquibase formatted sql
-- changeset SAMQA:1754374176730 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\mail_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/mail_type.sql:null:0b6608a192e72fdc24081f35643d899f0586255e:create

create or replace force editionable view samqa.mail_type (
    lookup_name,
    mail_code,
    mail_name
) as
    select
        lookup_name,
        lookup_code mail_code,
        meaning     mail_name
    from
        lookups
    where
        lookup_name = 'MAIL_TYPE';

