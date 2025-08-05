-- liquibase formatted sql
-- changeset SAMQA:1754374153561 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cms_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cms_external.sql:null:c69e2ce7dc178d7b28697ac03fd7c5dfb5baae9c:create

create table samqa.cms_external (
    cms_record varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' notrim
    ) location ( debit_card_dir : 'PCOB.BA.MR.GHPTIN.RESP.D20250421.T20260226.TXT' )
) reject limit 10;

