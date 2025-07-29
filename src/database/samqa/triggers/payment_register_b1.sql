create or replace editionable trigger samqa.payment_register_b1 before
    insert or update on samqa.payment_register
    for each row
begin
    if inserting then
        :new.created_by := get_user_id(v('APP_USER'));
        :new.creation_date := sysdate;
    end if;

    if updating then
        :new.last_updated_by := get_user_id(v('APP_USER'));
        :new.last_update_date := sysdate;
    end if;

end;
/

alter trigger samqa.payment_register_b1 enable;


-- sqlcl_snapshot {"hash":"9bd92d66ae330f029139e6a64545e8fc1c2dd303","type":"TRIGGER","name":"PAYMENT_REGISTER_B1","schemaName":"SAMQA","sxml":""}