-- liquibase formatted sql
-- changeset SAMQA:1754374166160 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\trg_insert_event.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/trg_insert_event.sql:null:10568efcf59723d137b72856925761cc8e0b3310:create

create or replace editionable trigger samqa.trg_insert_event after
    update of claim_status on samqa.claimn
    for each row
declare
    l_event_name   event_notifications.event_name%type;
    l_acc_id       account.acc_id%type;
    l_account_type account.account_type%type;
begin
    pc_log.log_error('TRG_INSERT_EVENT  -  NEW.CLAIM_STATUS ',
                     :new.claim_status);
    pc_log.log_error('TRG_INSERT_EVENT -  OLD.CLAIM_STATUS ',
                     :old.claim_status);
    if
        :old.claim_status <> :new.claim_status
        and :new.claim_status in ( 'DENIED', 'PAID' )
    then
        if :new.claim_status = 'DENIED' then
            l_event_name := 'CLAIM_DENIED';
        elsif
            :new.claim_status = 'PAID'
            and nvl(:new.denied_amount,
                    0) = 0
        then
            l_event_name := 'CLAIM_PROCESSED';
        end if;

        select
            acc_id,
            account_type
        into
            l_acc_id,
            l_account_type
        from
            account
        where
            pers_id = :new.pers_id;

        if l_account_type in ( 'FSA', 'HRA' ) then
            if
                l_event_name = 'CLAIM_PROCESSED'
                and nvl(:new.denied_amount,
                        0) = 0
            then
                pc_notification2.insert_events(
                    p_acc_id      => l_acc_id,
                    p_pers_id     => :new.pers_id,
                    p_event_name  => l_event_name,
                    p_entity_type => 'CLAIMN',
                    p_entity_id   => :new.claim_id
                );

            end if;
        else
            pc_notification2.insert_events(
                p_acc_id      => l_acc_id,
                p_pers_id     => :new.pers_id,
                p_event_name  => l_event_name,
                p_entity_type => 'CLAIMN',
                p_entity_id   => :new.claim_id
            );
        end if;

    end if;

end;
/

alter trigger samqa.trg_insert_event enable;

