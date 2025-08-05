-- liquibase formatted sql
-- changeset SAMQA:1754374165793 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\insure_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/insure_bf.sql:null:1a4c35144165667aab59df1d034c0f9bb3f6e166:create

create or replace editionable trigger samqa.insure_bf before
    insert or update on samqa.insure
    for each row
declare
    l_carrier_supported varchar2(1) := 'N';
    l_entrp_id          number;
begin
    for x in (
        select
            carrier_supported
        from
            enterprise
        where
            entrp_id = :new.insur_id
    ) loop
        :new.carrier_supported := x.carrier_supported;
    end loop;

    :new.allow_eob := 'Y';
end;
/

alter trigger samqa.insure_bf enable;

