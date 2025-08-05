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


-- sqlcl_snapshot {"hash":"2e8f289f3d8a2da9b67e8375cd2acfca198ea870","type":"TRIGGER","name":"INSURE_BF","schemaName":"SAMQA","sxml":""}