create or replace editionable trigger samqa.trg_updt_user before
    update on samqa.rate_plan_detail
    for each row
declare
    ls_last_update_user number;
begin
    ls_last_update_user := get_user_id(sys_context('APEX$SESSION', 'APP_USER'));
    if ls_last_update_user is not null then
        :new.last_updated_by := ls_last_update_user;
    end if;
    :new.last_update_date := sysdate;
end;
/

alter trigger samqa.trg_updt_user enable;


-- sqlcl_snapshot {"hash":"81dd014bc14468afa5fa0ee6ec5bc749c88b4653","type":"TRIGGER","name":"TRG_UPDT_USER","schemaName":"SAMQA","sxml":""}