-- liquibase formatted sql
-- changeset SAMQA:1754374142589 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\assign_salesrep.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/assign_salesrep.sql:null:70d6555e6b574881b7f72f4279febe588cb58234:create

create or replace procedure samqa.assign_salesrep as
    l_sales_team_member_id number;
    l_return_status        varchar2(1);
    l_error_message        varchar2(32000);
begin
    for x in (
        select
            *
        from
            account
        where
            acc_num in ( 'GPOP010246', 'GPOP010229', 'GPOP010254', 'GPOP010239', 'GPOP010235',
                         'GPOP010187', 'GPOP010236', 'GPOP010007', 'GPOP010147', 'GPOP010123',
                         'GPOP010249', 'GPOP010204', 'GPOP010260', 'GPOP010167', 'GPOP010120',
                         'GPOP010257', 'GPOP010210', 'GPOP010238', 'GPOP010252', 'GPOP014324',
                         'GPOP014933', 'GPOP014985', 'GPOP015318', 'GPOP017413', 'GPOP017414',
                         'GPOP017415', 'GPOP018920', 'GPOP019483', 'GPOP020058', 'GPOP020291',
                         'GPOP020295', 'GPOP020626', 'GPOP020866', 'GPOP020906', 'GPOP021316',
                         'GPOP021496', 'GPOP021754', 'GPOP022723' )
    ) loop
        pc_sales_team.upsert_sales_team_member(
            p_entity_type           => 'SALES_REP',
            p_entity_id             => 441,
            p_mem_role              => 'PRIMARY',
            p_entrp_id              => x.entrp_id,
            p_start_date            => sysdate,
            p_end_date              => null,
            p_status                => 'A',
            p_user_id               => 0,
            p_pay_commission        => 'Y',
            p_note                  => '**Salesrep Assignment',
            p_no_of_days            => null,
            px_sales_team_member_id => l_sales_team_member_id,
            x_return_status         => l_return_status,
            x_error_message         => l_error_message
        );
    end loop;
end;
/

