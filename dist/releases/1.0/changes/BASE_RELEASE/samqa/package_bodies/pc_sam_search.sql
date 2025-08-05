-- liquibase formatted sql
-- changeset SAMQA:1754374085967 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_sam_search.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_sam_search.sql:null:8e3da3364d2f31d15ce419d46887681dc1c72032:create

create or replace package body samqa.pc_sam_search as

    function f_search_subscriber (
        p_last_name       in varchar2 default null,
        p_first_name      in varchar2 default null,
        p_employer_name   in varchar2 default null,
        p_acc_num         in varchar2 default null,
        p_ssn             in varchar2 default null,
        p_acc_open_start  in date default null,
        p_acc_open_end    in date default null,
        p_acc_reg_start   in date default null,
        p_acc_reg_end     in date default null,
        p_acc_close_start in date default null,
        p_acc_close_end   in date default null,
        p_account_status  in varchar2 default null,
        p_complete_flag   in varchar2 default null,
        p_vendor_acc      in varchar2 default null,
        p_created_by      in number default null,
        p_carrier         in varchar2 default null,
        p_closed_reason   in varchar2 default null,
        p_sales_rep_id    in number default null,
        p_card_number     in number default null,
        p_account_type    in varchar2 default null,
        p_email           in varchar2 default null,
        p_fraud_acc       in varchar2 default null
    ) return result_person_t
        pipelined
        deterministic
    as

        l_result_person_rec result_person_rec;
        l_sql               varchar2(32000);
        w                   varchar2(32000);
        type search_cur is ref cursor;
        va_cur              search_cur;
        l_result_cursor_rec result_cursor_rec;
    begin

       /*             pc_log.app_logs('first_name '||p_FIRST_NAME);
                    pc_log.app_logs('p_last_NAME '||p_last_NAME);
                    pc_log.app_logs('p_EMPLOYER_NAME '||p_EMPLOYER_NAME);
                    pc_log.app_logs('p_SSN '||p_SSN);
                    pc_log.app_logs('p_ACC_NUM '||p_ACC_NUM);
                    pc_log.app_logs('p_ACCOUNT_STATUS '||p_ACCOUNT_STATUS);
                    pc_log.app_logs('p_SALES_REP_ID '||p_SALES_REP_ID);
                    pc_log.app_logs('p_EMAIL '||p_EMAIL);
                    pc_log.app_logs('p_CARD_NUMBER '||p_CARD_NUMBER);
                    pc_log.app_logs('p_COMPLETE_FLAG '||p_COMPLETE_FLAG);
                    pc_log.app_logs('p_CLOSED_REASON '||p_CLOSED_REASON);
                    pc_log.app_logs('p_ACCOUNT_TYPE '||p_ACCOUNT_TYPE);
                    pc_log.app_logs('p_CARRIER '||p_CARRIER);*/

                    -- TODO: Implementation required for FUNCTION PC_SAM_SEARCH.f_search_subscriber
        if
            nvl(p_first_name, '%') = '%'
            and nvl(p_last_name, '%') = '%'
            and nvl(p_employer_name, '%') = '%'
            and nvl(p_acc_num, '%') = '%'
            and nvl(p_ssn, '%') = '%'
            and p_acc_open_start is null
            and p_acc_open_end is null
            and p_acc_reg_start is null
            and p_acc_reg_end is null
            and p_acc_close_start is null
            and p_acc_close_end is null
            and nvl(p_account_status, '%') = '%'
            and nvl(p_complete_flag, '%') = '%'
            and nvl(p_vendor_acc, '%') = '%'
            and p_created_by is null
            and nvl(p_carrier, '%') = '%'
            and nvl(p_closed_reason, '%') = '%'
            and p_sales_rep_id is null
            and p_card_number is null
            and nvl(p_account_type, '%') = '%'
            and nvl(p_email, '%') = '%'
            and nvl(p_fraud_acc, '%') = '%'
        then
            raise_application_error('-20001', 'Enter atleast one search parameter to search subscriber ');
        end if;

        l_sql := '  select PERSON.PERS_ID PERS_ID, '
                 || '   NVL(ACCOUNT.BLOCKED_FLAG,''N'') BLOCKED_FLAG, '
                 || '  PERSON.FIRST_NAME, '
                 || '  PERSON.MIDDLE_NAME, '
                 || '   PERSON.LAST_NAME,'
                 || '   ''***-**-''||SUBSTR(PERSON.SSN,8,4) SSN, '
                 || '   ACCOUNT_TYPE, '
                 || '   ACCOUNT.ACC_NUM ACC_NUMC,  '
                 || '   PERSON.ENTRP_ID,  '
                 || '   TO_CHAR(ACCOUNT.START_DATE,''MM/DD/YYYY'') START_DATE, '
                 || '   TO_CHAR(ACCOUNT.END_DATE,''MM/DD/YYYY'') END_DATE, '
                 || '   ACCOUNT.ACCOUNT_STATUS,'
                 || '   ACCOUNT.COMPLETE_FLAG,'
                 || '   ACCOUNT.ACC_ID,'
                 || '   PERSON.PERS_MAIN, '
                 || '   ACCOUNT.CLOSED_REASON CLOSED_REASON, '
                 || '   ACCOUNT.AM_ID AM_ID, '
                 || '   ACCOUNT.SALESREP_ID SALESREP_ID, '
                 || '   ACCOUNT.BROKER_ID, '
                 || '   PERSON.CREATED_BY, '
                 || '   ACCOUNT.PLAN_CODE '
                 || '  from PERSON '
                 || '      ,ACCOUNT '
                 || '   WHERE PERSON.PERSON_TYPE <> ''BROKER''  '
                 || '   AND   ACCOUNT.PERS_ID(+) = PERSON.PERS_ID  ';

        if
            p_acc_num is not null
            and length(p_acc_num) = 9
        then
            w := w || ' AND  ACCOUNT.ACC_NUM =  :p_acc_num';
        elsif
            p_acc_num is not null
            and length(p_acc_num) < 9
        then
            w := w || ' AND ACCOUNT.ACC_NUM  LIKE ''%''||:p_acc_num||''%'' ';
        else
            w := w || '  AND  (1 = 1 OR :p_acc_num IS NULL )';
        end if;

        if p_first_name is not null then
            w := w || ' AND PERSON.FIRST_NAME  LIKE :p_first_name||''%'' ';
        else
            w := w || ' AND (1 = 1 OR :p_first_name IS NULL)';
        end if;

        if p_last_name is not null then
            w := w || ' AND PERSON.LAST_NAME  LIKE :p_last_name||''%'' ';
        else
            w := w || ' AND (1 = 1 OR :p_last_name IS NULL)';
        end if;

        if p_ssn is not null then
            if length(p_ssn) >= 9 then
                w := w || ' AND PERSON.SSN  = FORMAT_SSN(:p_ssn) ';
            elsif length(p_ssn) < 9 then
                w := w || ' AND PERSON.SSN  LIKE ''%''||:p_ssn ||''%'' ';
            end if;
        else
            w := w || ' AND (1 = 1 OR :p_ssn IS NULL) ';
        end if;

        if p_employer_name is not null then
            w := w || ' AND PERSON.ENTRP_ID IN ( SELECT ENTRP_ID FROM ENTERPRISE WHERE NAME LIKE ''%''||:p_employer_name||''%'' )';
        else
            w := w || ' AND (1 = 1 OR :p_employer_name IS NULL) ';
        end if;

        if
            p_acc_open_start is not null
            and p_acc_open_end is null
        then
            w := w || ' AND TRUNC(ACCOUNT.START_DATE) BETWEEN :p_acc_open_start AND SYSDATE ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_open_start IS NULL) ';
        end if;

        if
            p_acc_open_start is null
            and p_acc_open_end is not null
        then
            w := w || ' AND TRUNC(ACCOUNT.START_DATE) <= :p_acc_open_end  ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_open_start IS NULL) ';
        end if;

        if
            p_acc_open_start is not null
            and p_acc_open_end is not null
        then
            w := w || ' AND TRUNC(ACCOUNT.START_DATE) BETWEEN :p_acc_open_start AND :p_acc_open_end ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_open_start IS NULL OR :p_acc_open_end IS NULL) ';
        end if;

        if
            p_acc_reg_start is not null
            and p_acc_reg_end is null
        then
            w := w || ' AND TRUNC(ACCOUNT.REG_DATE) BETWEEN :p_acc_reg_start AND SYSDATE ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_reg_start IS NULL )';
        end if;

        if
            p_acc_reg_start is null
            and p_acc_reg_end is not null
        then
            w := w || ' AND TRUNC(ACCOUNT.REG_DATE) <= :p_acc_reg_end ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_reg_end IS NULL )';
        end if;

        if
            p_acc_reg_start is not null
            and p_acc_reg_end is not null
        then
            w := w || ' AND TRUNC(ACCOUNT.REG_DATE) >= :p_acc_reg_start 
                                AND  TRUNC(ACCOUNT.REG_DATE) <= :p_acc_reg_end ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_reg_start IS NULL OR  :p_acc_reg_end IS NULL) ';
        end if;

        if
            p_acc_close_start is not null
            and p_acc_close_end is null
        then
            w := w || ' AND TRUNC(ACCOUNT.END_DATE) BETWEEN :p_acc_close_start AND SYSDATE ';
        else
            w := w || ' AND (1 = 1 OR :p_acc_close_start IS NULL ) ';
        end if;

        if
            p_acc_close_start is null
            and p_acc_close_end is not null
        then
            w := w || ' AND TRUNC(ACCOUNT.END_DATE) <= :p_acc_close_end ';
        else
            w := w || ' AND (1 = 1  OR  :p_acc_close_end IS NULL) ';
        end if;

        if
            p_acc_close_start is not null
            and p_acc_close_end is not null
        then
            w := w || ' AND TRUNC(ACCOUNT.END_DATE) 
                               BETWEEN :p_acc_close_start AND :p_acc_close_end ';
        else
            w := w || ' AND (1 = 1  OR  :p_acc_close_start IS NULL OR :p_acc_close_end IS NULL) ';
        end if;

        if
            p_account_status is not null
            and p_account_status <> -1
        then
            w := w || ' AND ACCOUNT.ACCOUNT_STATUS = :p_account_status';
        else
            w := w || ' AND (1 = 1  OR  :p_account_status IS NULL ) ';
        end if;

        if
            p_complete_flag is not null
            and p_complete_flag <> -1
        then
            w := w || ' AND ACCOUNT.COMPLETE_FLAG = :p_complete ';
                     -- if it is incomplete exclude the closed accounts as they non funded
            if p_complete_flag = 0 then
                w := w || ' AND ACCOUNT.ACCOUNT_STATUS <> 4';
            end if;
        else
            w := w || ' AND (1 = 1  OR  :p_complete IS NULL ) ';
        end if;

        if p_vendor_acc is not null then
            w := w || ' AND PERSON.ORIG_SYS_VENDOR_REF = :p_vendor_acc  ';
        else
            w := w || ' AND (1 = 1  OR  :p_vendor_acc IS NULL ) ';
        end if;

        if
            p_created_by is not null
            and p_created_by <> -1
        then
            w := w || ' AND PERSON.CREATED_BY =:p_created_by  ';
        else
            w := w || ' AND (1 = 1  OR  :p_created_by IS NULL ) ';
        end if;

        if
            p_carrier is not null
            and p_carrier <> -1
        then
            w := w || ' AND INSURE.PERS_ID IN ( SELECT PERS_ID FROM INSURE 
                                                       WHERE INSUR_ID = :p_carrier) ';
        else
            w := w || ' AND (1 = 1  OR  :p_carrier IS NULL ) ';
        end if;

        if p_closed_reason is not null then
            w := w || ' AND ACCOUNT.CLOSED_REASON = :p_closed_reason  ';
        else
            w := w || ' AND (1 = 1  OR  :p_closed_reason IS NULL ) ';
        end if;

        if
            p_sales_rep_id is not null
            and p_sales_rep_id <> -1
        then
            w := w || ' AND ACCOUNT.SALESREP_ID = :p_salesrep_id  ';
        else
            w := w || ' AND (1 = 1  OR  :p_salesrep_id IS NULL ) ';
        end if;

        if p_card_number is not null then
            w := w || ' AND PERS_ID IN ( SELECT CARD_ID FROM CARD_DEBIT WHERE CARD_DEBIT.CARD_NUMBER = :p_card_number  ) ';
        else
            w := w || ' AND (1 = 1  OR  :p_card_number IS NULL ) ';
        end if;

        if p_account_type <> '-1' then
            w := w || ' AND ACCOUNT.ACCOUNT_TYPE = :p_account_type ';
        else
            w := w || ' AND (1 = 1  OR  :p_account_type IS NULL ) ';
        end if;

        if
            p_fraud_acc = 'Y'
            and p_account_type = 'HSA'
        then
            w := w || ' AND ACCOUNT.BLOCKED_FLAG= :p_blocked_flag ';
        else
            w := w || ' AND (1 = 1  OR  :p_blocked_flag IS NULL ) ';
        end if;

        if p_email is not null then
            w := w || ' AND PERSON.EMAIL = :p_email ';
        else
            w := w || ' AND (1 = 1  OR  :p_email IS NULL ) ';
        end if;

        if
            p_fraud_acc = 'N'
            and p_account_type = 'HSA'
        then
            w := w || ' AND (ACCOUNT.BLOCKED_FLAG IS NULL OR ACCOUNT.BLOCKED_FLAG =''N'')';
        else
            w := w || ' AND (1 = 1  OR  :fraud_acc IS NULL ) ';
        end if;
                  
                  
                  
                  
                             --         pc_log.app_logs('sql '||l_sql||' '||w);

        open va_cur for l_sql || w
            using p_acc_num, p_first_name, p_last_name, p_ssn, p_employer_name, p_acc_open_start, p_acc_open_end, p_acc_open_start, p_acc_open_end
            , p_acc_reg_start, p_acc_reg_end, p_acc_reg_start, p_acc_reg_end, p_acc_close_start, p_acc_close_end, p_acc_close_start, p_acc_close_end
            , p_account_status, p_complete_flag, p_vendor_acc, p_created_by, p_carrier, p_closed_reason, p_sales_rep_id, p_card_number
            , p_account_type, p_fraud_acc, p_email, p_fraud_acc;

        loop
            fetch va_cur into l_result_cursor_rec;
            exit when va_cur%notfound;
            l_result_person_rec.first_name := l_result_cursor_rec.first_name;
            l_result_person_rec.middle_name := l_result_cursor_rec.middle_name;
            l_result_person_rec.last_name := l_result_cursor_rec.last_name;
            l_result_person_rec.ssn := l_result_cursor_rec.ssn;
            l_result_person_rec.account_type := l_result_cursor_rec.account_type;
            l_result_person_rec.acc_num := l_result_cursor_rec.acc_num;
            l_result_person_rec.blocked_flag := l_result_cursor_rec.blocked_flag;
            l_result_person_rec.start_date := l_result_cursor_rec.start_date;
            l_result_person_rec.end_date := l_result_cursor_rec.end_date;
            l_result_person_rec.account_status := pc_lookups.get_account_status(l_result_cursor_rec.account_status);
            l_result_person_rec.complete_flag :=
                case
                    when
                        l_result_cursor_rec.acc_num is not null
                        and l_result_cursor_rec.complete_flag = 1
                    then
                        'Yes'
                    else 'No'
                end;

            l_result_person_rec.closed_reason := l_result_cursor_rec.closed_reason;
            l_result_person_rec.primary_account := pc_person.acc_num(l_result_cursor_rec.pers_main);
            l_result_person_rec.account_manager := pc_account.get_salesrep_name(l_result_cursor_rec.am_id);
            l_result_person_rec.salesrep := pc_account.get_salesrep_name(l_result_cursor_rec.salesrep_id);
            if l_result_cursor_rec.acc_num is not null then
                if
                    l_result_cursor_rec.account_status = 4
                    and l_result_cursor_rec.complete_flag = 0
                then
                    l_result_person_rec.account_status := 'Closed for No Funds';
                else
                    l_result_person_rec.account_status := pc_lookups.get_account_status(l_result_cursor_rec.account_status);
                end if;
            else
                l_result_person_rec.account_status := 'Account is not created';
            end if;

            l_result_person_rec.broker_name := pc_account.get_broker(l_result_cursor_rec.broker_id);
            l_result_person_rec.user_name := get_user_name(l_result_cursor_rec.created_by);
            l_result_person_rec.plan_name := pc_plan.plan_name(l_result_cursor_rec.plan_code);
            l_result_person_rec.primary_person := pc_person.get_person_name(l_result_cursor_rec.pers_main);
            l_result_person_rec.pers_id := l_result_cursor_rec.pers_id;
            l_result_person_rec.entrp_id := l_result_cursor_rec.entrp_id;
            l_result_person_rec.acc_id := l_result_cursor_rec.acc_id;
            l_result_person_rec.pers_main := l_result_cursor_rec.pers_main;
            if l_result_cursor_rec.account_type = 'HSA' then
                for x in (
                    select
                        to_char(
                            min(fee_date),
                            'MM/DD/YYYY'
                        ) fee_date
                    from
                        income
                    where
                        income.acc_id = l_result_cursor_rec.acc_id
                ) loop
                    l_result_person_rec.first_activity_date := x.fee_date;
                end loop;
            end if;

            pipe row ( l_result_person_rec );
        end loop;

        close va_cur;
    end f_search_subscriber;

end pc_sam_search;
/

