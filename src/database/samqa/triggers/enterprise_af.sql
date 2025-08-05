create or replace editionable trigger samqa.enterprise_af after
    insert or update on samqa.enterprise
    for each row
begin
    if :old.note <> :new.note then
        pc_utility.insert_notes(:new.entrp_id,
                                'ENTERPRISE',
                                :new.note,
                                get_user_id(v('APP_USER')),
                                sysdate,
                                null,
                                null,
                                :old.entrp_id);

    end if;
end;
/

alter trigger samqa.enterprise_af enable;


-- sqlcl_snapshot {"hash":"4d2ab31420db86ae63351600512c92b5067a9f84","type":"TRIGGER","name":"ENTERPRISE_AF","schemaName":"SAMQA","sxml":""}