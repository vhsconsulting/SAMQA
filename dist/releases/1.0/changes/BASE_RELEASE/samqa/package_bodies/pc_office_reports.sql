-- liquibase formatted sql
-- changeset SAMQA:1754374064765 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_office_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_office_reports.sql:null:71dae00f00aaddcc0c752051d34c1cb8d5ab545c:create

create or replace package body samqa.pc_office_reports as

/*
 FUNCTION CLaims_report_BY_TYPE
     (p_entrp_id        IN NUMBER
    ,p_plan_start_date IN DATE
     ,p_plan_end_date   IN DATE) 
     RETURN cLOB  is
     l_CLaims_report CLOB; 
    Begin

    null; 
    ENd ;
    /*

            (    SELECT json_arrayagg(
                               json_object(
                                KEY 'filename' value 'Contribution_Aggregated_'||AC.ACC_NUM||'.pdf',
                                KEY 'data' VALUE json_arrayagg (json_object (
                                KEY 'curr_date' VALUE to_char(sysdate,'MM/DD/YYYY')
                               , KEY 'START_DATE' VALUE to_char(p_Plan_start_date,'MM/DD/YYYY')    
                               , KEY 'END_DATE' VALUE   to_char(p_Plan_End_date,'MM/DD/YYYY')     
                                ,KEY 'S_EE_AMT'      VALUE  '$'||TO_CHAR(l_SUM_EE,'fm9999G990D00')      
                                ,KEY 'S_ER_AMT'      VALUE   '$'||TO_CHAR(l_SUM_ER,'fm9999G990D00')    
                                ,KEY 'S_ALL_AMT'      VALUE  '$'||TO_CHAR(l_SUM_all,'fm9999G990D00')       
                                ,KEY 'ACC_NUM' VALUE AC.ACC_NUM
                                ,Key 'ER_ADD1'  Value  PC_ENTRP.get_entrp_name(P_ENTRP_ID)  
                                ,Key 'ER_ADD2'  Value PC_ENTRP.GET_CITY(P_ENTRP_ID)    
                                ,Key 'ER_ADD3'  Value  PC_ENTRP.GET_STATE(P_ENTRP_ID)  || ' - ' ||  ER.zip ,
												 KEY 'EMPLOYER'  VALUE (SELECT json_arrayagg(
                                                   json_object
                                                         ( key 'PL_DET' VALUE  (SELECT json_arrayagg(
                                                                      json_object
															( Key  'ACC_NUM'  Value   Acc_Num  ,
                                                                    Key  'EMP_NAME'  Value     First_Name || ' ' || Last_Name,
                                                                    Key  'PAY_DATE'  Value  PAY_DATE,  --- to_char(PAY_DATE,'MM/DD/YYYY')  ,
                                                                    Key  'APPROVED_AMOUNT'  Value    '$'||TO_CHAR(APPROVED_AMOUNT,'fm9999G990D00')     ,
                                                                    Key  'CLAIM_PENDING'  Value       CLAIM_PENDING ,
                                                                    Key  'CHECK_AMOUNT'  Value    '$'||TO_CHAR(CHECK_AMOUNT,'fm9999G990D00')     ,
                                                                    Key  'CHECK_NUMBER'  Value       CHECK_NUMBER ,
                                                                    Key  'CLAIM_AMOUNT'  Value    '$'||TO_CHAR(CLAIM_AMOUNT,'fm9999G990D00')       ,
                                                                    Key  'TRANSACTION_NUMBER'  Value       TRANSACTION_NUMBER ,
                                                                    Key  'REIMBURSEMENT_METHOD'  Value     REIMBURSEMENT_METHOD,
                                                               ---     Key  'DIVISION_CODE'  Value       DIVISION_CODE ,
                                                                    Key  'DIVISION_NAME'  Value     DIVISION_NAME,
                                                            ---        Key  'REASON_CODE'  Value       REASON_CODE ,
                                                                    Key  'SERVICE_TYPE'  Value     SERVICE_TYPE,
                                                                 --   Key  'SERVICE_TYPE_MEANING'  Value       SERVICE_TYPE_MEANING ,
                                                                    Key  'DENIED_AMOUNT'  Value     DENIED_AMOUNT,
                                                                    Key  'PLAN_START_DATE'  Value       p_plan_start_date ,
                                                                    Key  'PLAN_END_DATE'  Value      p_plan_end_date)  )
                       FROM 
                                 (select 
                                                                 SERVICE_TYPE ,
                                                                 ACC_NUM,
                                                                 FIRST_NAME,
                                                                 LAST_NAME,
                                                                 max(to_char(PAY_DATE,'mm/dd/yyyy'))  PAY_DATE,
                                                               sum(APPROVED_AMOUNT) APPROVED_AMOUNT ,
                                                               sum(CLAIM_PENDING)  CLAIM_PENDING , 
                                                                 sum(CHECK_AMOUNT) CHECK_AMOUNT  ,
                                                                 sum(CHECK_NUMBER) CHECK_NUMBER ,
                                                                 sum(CLAIM_AMOUNT) CLAIM_AMOUNT  ,
                                                              max( TRANSACTION_NUMBER) TRANSACTION_NUMBER,
                                                              max( REIMBURSEMENT_METHOD) REIMBURSEMENT_METHOD,
                                                               max(  DIVISION_NAME) DIVISION_NAME ,
                                                             sum( DENIED_AMOUNT) DENIED_AMOUNT ,
                                                              max( PLAN_START_DATE),
                                                              max(PLAN_END_DATE)
                                                         from CLAIM_REPORT_ONLINE_V
                                                         where ENTRP_ID = p_entrp_id
                                                         and   TRUNC(PLAN_START_DATE) >= p_plan_start_date
                                                         and   TRUNC(PLAN_END_DATE) <= p_plan_end_date
                                                             AND s.lookup_Code = SERVICE_TYPE 
                                                         Group  by  SERVICE_TYPE  , ACC_NUM, FIRST_NAME, LAST_NAME  
                                                     UNION ALL
                                                       Select   B.SERVICE_TYPE  ,
                                                                C.ACC_NUM ACC_NUM,
                                                                FIRST_NAME,
                                                                LAST_NAME,
                                                                NULL PAY_DATE
                                                                , sum(B.APPROVED_AMOUNT) APPROVED_AMOUNT
                                                                ,sum(B.CLAIM_PENDING) CLAIM_PENDING
                                                                , NULL CHECK_AMOUNT   
                                                                , NULL CHECK_NUMBER
                                                                , sum(TO_NUMBER(B.CLAIM_AMOUNT))  CLAIM_AMOUNT
                                                                , sum(B.CLAIM_ID) TRANSACTION_NUMBER
                                                                , NULL REIMBURSEMENT_METHOD
                                                                ,  max(PC_PERSON.GET_DIVISION_NAME(B.PERS_ID)) DIVISION_NAME
                                                              , sum(b.DENIED_AMOUNT)  DENIED_AMOUNT
                                                                , max (b.PLAN_START_DATE)  PLAN_START_DATE
                                                                , max(B.PLAN_END_DATE)  PLAN_END_DATE
                                                         FROM PAYMENT_REGISTER A ,
                                                          CLAIMN B ,
                                                          ACCOUNT C ,
                                                          PERSON E
                                                          WHERE A.ENTRP_ID   = B.ENTRP_ID
                                                          AND E.ENTRP_ID     = B.ENTRP_ID 
                                                          AND A.CLAIM_ID     = B.CLAIM_ID
                                                          AND E.PERS_ID      = B.PERS_ID
                                                          AND C.PERS_ID      = B.PERS_ID  ---New
                                                          AND B.CLAIM_STATUS = 'DENIED'
                                                          AND B.entrp_id = p_entrp_id
                                                          AND B.CLAIM_STATUS NOT IN ('ERROR','CANCELLED')
                                                          and   TRUNC(CLAIM_DATE) >= p_plan_start_date
                                                          and   TRUNC(CLAIM_DATE) <= p_plan_end_date
                                                              AND s.lookup_Code = SERVICE_TYPE 
                                                          group by B.SERVICE_TYPE  , C.ACC_NUM, FIRST_NAME, LAST_NAME  
                                                      UNION ALL
                                                      (           Select                   SERVICE_TYPE,
                                                                                               C.ACC_NUM,
                                                                                                FIRST_NAME,
                                                                                                LAST_NAME,
                                                                                                NULL PAY_DATE
                                                                                                ,SUM( B.APPROVED_AMOUNT) APPROVED_AMOUNT
                                                                                                , SUM(B.CLAIM_PENDING) CLAIM_PENDING
                                                                                                , NULL CHECK_AMOUNT
                                                                                                , NULL CHECK_NUMBER
                                                                                                ,SUM( TO_NUMBER(B.CLAIM_AMOUNT) )  CLAIM_AMOUNT
                                                                                                , MAX(B.CLAIM_ID)  TRANSACTION_NUMBER
                                                                                                , NULL REIMBURSEMENT_METHOD
                                                                                                 , MAX( PC_PERSON.GET_DIVISION_NAME(C.PERS_ID)) DIVISION_NAME
                                                                                                , SUM(B.DENIED_AMOUNT)  DENIED_AMOUNT
                                                                                                ,MAX( B.PLAN_START_DATE) PLAN_START_DATE
                                                                                                , MAX(B.PLAN_END_DATE)  PLAN_END_DATE
                                                          from   HRAFSA_DEBIT_CARD_CLAIMS_V B , account c
                                                       where b.ENTRP_ID = P_ENTRP_ID
                                                       AND c.ACC_NUM = b.ACC_NUM
                                                       and   TRUNC(CLAIM_DATE) >= p_plan_start_date
                                                       and   TRUNC(CLAIM_DATE) <= p_plan_end_date    
                                                         AND  CLAIM_STATUS NOT IN ('ERROR','CANCELLED')
                                                          AND s.lookup_Code = SERVICE_TYPE 
                                                        Group By SERVICE_TYPE ,C.ACC_NUM, FIRST_NAME, LAST_NAME  
                                                            ) 
                                                  )returning clob)returning clob)
                                                 FROM   (select lookup_Code  from lookups where  lookup_name  ='FSA_PLAN_TYPE' )   S 
                                        )  
            returning clob)
                    returning clob)
            returning clob)
                    returning clob)
               files
                   ---     INTO l_CLaims_report 
                        ----files
              FROM ENTERPRISE ER, ACCOUNT AC
              WHERE ER.ENTRP_ID = NVL(P_ENTRP_ID ,ER.ENTRP_ID)
              AND   ER.ENTRP_ID = AC.ENTRP_ID
           ---   AND   AC.ACCOUNT_STATUS = 1
               GROUP BY ER.ENTRP_ID ,AC.ACC_NUM ) 
               Loop 
                   l_CLaims_report := x.files ; 
               ENd Loop; 

          RETURN l_CLaims_report ;  
       -----    End Loop;  

    End CLaims_report_BY_TYPE;
    */

    function get_ga_monthly_stmt (
        p_ga_id         in varchar2,
        p_account_type  in varchar2,
        p_inv_date_from in date,
        p_inv_date_to   in date
    ) return clob is
        l_ga_monthly_stmt clob;
        l_sum_total       number := 0;
        l_name            varchar2(100);
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'GA_MONTHLY_STATEMENT'
                                             || p_ga_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'AGENCY_NAME' value ga.agency_name,
                                        key 'AGENCY_ADD1' value ga.address
                                                                || ' '
                                                                || ga.city,
                                        key 'AGENCY_ADD2' value ga.state
                                                                || ' - '
                                                                || ga.zip,
                                        key 'START_DATE' value to_char(p_inv_date_from, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_inv_date_to, 'MM/DD/YYYY'),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'EMPLOYER' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PL_DET' value(
                                                    select
                                                        json_arrayagg(
                                                            json_object( --- KEY 'PLAN_TYPE'       VALUE      a.plan_type  
                                                                key 'CLIENT_NAME' value e.name,
                                                                        key 'ACC_NUM' value a.acc_num,
                                                                        key 'INVOICE_ID' value ar.invoice_id,
                                                                        key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'
                                                                        ),
                                                                        key 'START_DATE' value to_char(ar.start_date, 'MM/DD/YYYY'),
                                                                        key 'END_DATE' value ar.end_date,
                                                                        key 'DESCRIPTION' value arl.description,
                                                                        key 'QUANTITY' value arl.quantity,
                                                                        key 'NO_OF_MONTHS' value arl.no_of_months,
                                                                        key 'UNIT_RATE_COST' value arl.unit_rate_cost,
                                                                        key 'TOTAL_LINE_AMOUNT' value arl.total_line_amount
                                                            returning clob)
                                                        returning clob)
                                                    from
                                                        ar_invoice         ar,
                                                        ar_invoice_lines   arl,
                                                        account            a,
                                                        enterprise         e,
                                                        invoice_parameters ip
                                                    where
                                                            a.ga_id = p_ga_id
                                                        and ar.invoice_id = arl.invoice_id
                                                        and ar.entity_id = a.entrp_id
                                                        and ar.entity_type = 'EMPLOYER'
                                                        and ip.entity_id = a.entrp_id
                                                        and ip.entity_type = 'EMPLOYER'
                                                        and ar.rate_plan_id = ip.rate_plan_id
                                                        and ip.status = 'A'
                                                        and ip.invoice_type = 'FEE'
                                                        and ar.approved_date is not null
                                                        and a.entrp_id = e.entrp_id
                                                        and ar.invoice_reason = 'FEE'
                                                        and ar.status = 'PROCESSED' --9914
                                                        and arl.status <> 'VOID'
                                                        and arl.status not in('VOID', 'CANCELLED')
                                                        and((p_account_type = 'HRAFSA'
                                                             and a.account_type in('FSA', 'HRA')
                                                             and arl.invoice_line_type <> 'FLAT_FEE')
                                                            or(p_account_type = a.account_type
                                                               and ip.invoice_frequency = 'MONTHLY'))
                                                        and ar.invoice_date between nvl(p_inv_date_from, ar.invoice_date) and nvl(p_inv_date_to
                                                        , ar.invoice_date)
                                                    group by
                                                        e.name,
                                                        a.acc_num,
                                                        ar.invoice_id,
                                                        ar.invoice_date,
                                                        ar.start_date,
                                                        ar.end_date,
                                                        arl.description,
                                                        arl.quantity,
                                                        arl.no_of_months,
                                                        arl.unit_rate_cost,
                                                        arl.total_line_amount
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select
                                                lookup_code
                                            from
                                                lookups
                                            where
                                                lookup_name = 'FSA_PLAN_TYPE'
                                        ) s
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise    er,
                account       ac,
                ar_invoice    ar,
                general_agent ga
            where
                    er.entrp_id = ac.entrp_id
                and ar.entity_id = ac.entrp_id
                and ac.ga_id = p_ga_id
                and ac.ga_id = ga.ga_id
                and ga.ga_id = p_ga_id
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_ga_monthly_stmt := x.files;
        end loop;

        return l_ga_monthly_stmt;
    end get_ga_monthly_stmt;

    function get_contribution_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is

        l_contrib_clob  clob;
        l_division_code varchar2(10);
        l_record        pc_office_reports.plan_type_totals_t;
        l_ctr           number := 0; 
/*
    l_SUM_ER string_asc_arr_t;
    l_SUM_EE string_asc_arr_t;
    l_SUM_all string_asc_arr_t;
    l_GSUM_ER string_asc_arr_t;
    l_GSUM_EE string_asc_arr_t;
    l_GSUM_all string_asc_arr_t; */
        l_sum_er        number := 0;
        l_sum_ee        number := 0;
        l_sum_all       number := 0;
        l_idx           varchar2(50);
        l_all_types     varchar2(1000);
    begin
        for i in (
            select
                plan_type,
                sum(er_amount)             sum_er,
                sum(ee_amount)             sum_ee,
                sum(ee_amount + er_amount) sum_all
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = p_entrp_id
            group by
                plan_type
            order by
                plan_type
        ) loop
            l_all_types := l_all_types || i.plan_type;
            l_sum_er := i.sum_er + l_sum_er;
            l_sum_ee := l_sum_ee + i.sum_ee;
            l_sum_all := l_sum_all + l_sum_ee + l_sum_er;
        end loop;

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Contribution_Aggregated_'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'S_EE_AMT' value '$' || to_char(l_sum_ee, 'fm9999G990D00'),
                                        key 'S_ER_AMT' value '$' || to_char(l_sum_er, 'fm9999G990D00'),
                                        key 'S_ALL_AMT' value '$' || to_char(l_sum_all, 'fm9999G990D00'),
                                        key 'ACC_NUM' value ac.acc_num,
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'PLAN_DET' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PLAN_TYPE' value plan_type,
                                                key 'PLAN_DESC' value plan_type_meaning
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select distinct
                                                plan_type,
                                                plan_type_meaning
                                            from
                                                fsa_hra_er_ben_plans_v plans_v
                                            where
                                                plans_v.entrp_id = p_entrp_id
                                        )
                                ),
                                        key 'EMPLOYER' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PL_DET' value(
                                                    select
                                                        json_arrayagg(
                                                            json_object( -- KEY 'PLAN_TYPE'       VALUE      a.plan_type 
                                                                key 'PLAN_TYPE' value pc_lookups.get_fsa_plan_type(a.plan_type),
                                                                        key 'DIVISION_NAME' value division_name,
                                                                        key 'ACC_NUM' value a.acc_num,
                                                                        key 'FULL_NAME' value name,
                                                                        key 'FIRST_NAME' value first_name,
                                                                        key 'LAST_NAME' value last_name,
                                                                        key 'EE_AMOUNT' value sum(a.ee_amount) -- '$'||TO_CHAR(Sum(A.EE_AMOUNT),'fm9999G990D00')   
                                                                        ,
                                                                        key 'ER_AMOUNT' value sum(a.er_amount) --  '$'||TO_CHAR(Sum(A.ER_AMOUNT),'fm9999G990D00')    
                                                                        ,
                                                                        key 'T_AMT' value sum(ee_amount + er_amount) --'$'||TO_CHAR( Sum(  EE_AMOUNT+ ER_AMOUNT ),'fm9999G990D00')     
                                                            returning clob)
                                                        returning clob)
                                                    from
                                                        ee_deposits_v a
                                                    where
                                                            a.fee_date >= to_date(p_plan_start_date, 'MM/DD/YYYY')
                                                        and a.fee_date <= to_date(p_plan_end_date, 'MM/DD/YYYY')
                                                        and s.lookup_code = a.plan_type
                                                        and a.entrp_id = p_entrp_id
                                                    group by
                                                        a.plan_type,
                                                        division_name,
                                                        a.acc_num,
                                                        name,
                                                        first_name,
                                                        last_name
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select
                                                lookup_code
                                            from
                                                lookups
                                            where
                                                lookup_name = 'FSA_PLAN_TYPE'
                                        ) s
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
          ---    AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_contrib_clob := j.files;
        end loop;

        return l_contrib_clob;
    end get_contribution_type;

    function get_contribution_details_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is

        l_contrib_clob  clob;
        l_division_code varchar2(10);
        l_record        pc_office_reports.plan_type_totals_t;
        l_ctr           number := 0; 
/*
    l_SUM_ER string_asc_arr_t;
    l_SUM_EE string_asc_arr_t;
    l_SUM_all string_asc_arr_t;
    l_GSUM_ER string_asc_arr_t;
    l_GSUM_EE string_asc_arr_t;
    l_GSUM_all string_asc_arr_t; */
        l_sum_er        number := 0;
        l_sum_ee        number := 0;
        l_sum_all       number := 0;
        l_idx           varchar2(50);
        l_all_types     varchar2(1000);
    begin
        for i in (
            select
                plan_type,
                sum(er_amount)             sum_er,
                sum(ee_amount)             sum_ee,
                sum(ee_amount + er_amount) sum_all
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date   
                --- AND ACC_NUM Like 'FSA%'
                and entrp_id = p_entrp_id
            group by
                plan_type
            order by
                plan_type
        ) loop
            l_all_types := l_all_types || i.plan_type;
            l_sum_er := i.sum_er + l_sum_er;
            l_sum_ee := l_sum_ee + i.sum_ee;
            l_sum_all := l_sum_ee + l_sum_er;
        end loop;

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Contribution_Aggregated_'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'S_EE_AMT' value l_sum_ee,
                                        key 'S_ER_AMT' value l_sum_er,
                                        key 'S_ALL_AMT' value l_sum_ee + l_sum_er,
                                        key 'ACC_NUM' value ac.acc_num,
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ER_PHONE' value er.entrp_phones
             /*   ,KEY 'S_EE_HRA_AMT'      VALUE  l_SUM_EE('HRA')
                ,KEY 'S_ER_HRA_AMT'      VALUE  l_SUM_ER('HRA') 
                ,KEY 'S_ALL_HRA_AMT'      VALUE  l_SUM_all('HRA') 
                ,KEY 'S_EE_FSA_AMT'      VALUE  l_SUM_EE('FSA')
                ,KEY 'S_ER_FSA_AMT'      VALUE  l_SUM_ER('FSA') 
                ,KEY 'S_ALL_FSA_AMT'      VALUE  l_SUM_all('FSA') 
               ,KEY 'S_EE_DCA_AMT'      VALUE  l_SUM_EE('DCA')
                ,KEY 'S_ER_DCA_AMT'      VALUE  l_SUM_ER('DCA') 
                ,KEY 'S_ALL_DCA_AMT'      VALUE  l_SUM_all('DCA')
                ,KEY 'S_EE_LPF_AMT'      VALUE  l_SUM_EE('LPF')
                ,KEY 'S_ER_LPF_AMT'      VALUE  l_SUM_ER('LPF') 
                ,KEY 'S_ALL_LPF_AMT'      VALUE  l_SUM_all('LPF') 
                  ,KEY 'S_EE_PKG_AMT'      VALUE  Decode( instr(l_all_types, 'PKG') , 0 , 0 , l_SUM_EE('PKG')  )
                ,KEY 'S_ER_PKG_AMT'      VALUE  l_SUM_ER('PKG') 
                ,KEY 'S_ALL_PKG_AMT'      VALUE  l_SUM_all('PKG')
                ,KEY 'S_EE_TRN_AMT'      VALUE  l_SUM_EE('TRN')
                ,KEY 'S_ER_TRN_AMT'      VALUE  l_SUM_ER('TRN') 
                ,KEY 'S_ALL_TRN_AMT'      VALUE  l_SUM_all('TRN') */,
                                        key 'PLAN_DET' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PLAN_TYPE' value plan_type,
                                                key 'PLAN_DESC' value plan_type_meaning
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select distinct
                                                plan_type,
                                                plan_type_meaning
                                            from
                                                fsa_hra_er_ben_plans_v plans_v
                                            where
                                                plans_v.entrp_id = p_entrp_id
                                        )
                                ),
                                        key 'EMPLOYER' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PLAN_TYPE' value s.meaning,
                                                        key 'ACC_NUM' value a.acc_num,
                                                        key 'FULL_NAME' value a.name,
                                                        key 'EE_AMOUNT' value a.ee_amount,
                                                        key 'ER_AMOUNT' value a.er_amount,
                                                        key 'T_AMT' value a.ee_amount + a.er_amount,
                                                        key 'DIVISION_NAME' value a.division_name,
                                                        key 'FIRST_NAME' value a.first_name,
                                                        key 'LAST_NAME' value a.last_name,
                                                        key 'FEE_DATE' value to_char(a.fee_date, 'MM/DD/YYYY')
                                            returning clob)
                                        returning clob)
                                    from
                                        ee_deposits_v a,
                                        (
                                            select
                                                lookup_code,
                                                meaning
                                            from
                                                lookups
                                            where
                                                lookup_name = 'FSA_PLAN_TYPE'
                                        )             s
                                    where
                                            a.fee_date >= p_plan_start_date
                                        and a.fee_date <= p_plan_end_date
                                        and s.lookup_code = a.plan_type
                                        and a.entrp_id = p_entrp_id
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
      ---        AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_contrib_clob := j.files;
        end loop;

        return l_contrib_clob;
    end get_contribution_details_type;

    function claims_report (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2 default 'ALL',
        p_start_date      in date,
        p_end_date        in date,
        p_division_code   in varchar2,
        p_product_type    in varchar2
    ) return clob is
        l_claims_report clob;
        l_part_reim     number;
        l_provider_pay  number;
        l_total_sal     number;
        l_denied_amt    number;
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'CLaims_report'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'EMP_ADDR1' value er.address,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'EMP_ADDR2' value er.city
                                                              || ', '
                                                              || er.state
                                                              || ' '
                                                              || er.zip,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'PLAN_DET' value json_query(pc_office_reports.get_plans_json(p_entrp_id, p_plan_start_date
                                        , p_plan_end_date),
           '$' returning clob),
                                        key 'CLAIMS' value json_query(pc_office_reports.get_all_claims_json(p_entrp_id, p_plan_start_date
                                        , p_plan_end_date, p_start_date, p_end_date,
                                                                                                            'MANUAL', p_plan_type, p_product_type
                                                                                                            ),
           '$' returning clob)
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
                   ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_claims_report := j.files; 
                                ---  l_total_sal := j.CLAIMS.total_sal;
        end loop;

        return l_claims_report;
    end;
-- VANITHA TO HARI :  WE MAY NOT NEED THIS 
    function claims_report_by_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2,
        p_service_type    in varchar2
    ) return clob is
        l_claims_report clob;
        l_part_reim     number;
        l_provider_pay  number;
        l_total_sal     number;
        l_denied_amt    number;
    begin
        pc_log.log_error('CLaims_report', 'p_plan_type '
                                          || p_plan_type
                                          || ' p_entrp_id '
                                          || p_entrp_id
                                          || ' p_plan_start_date '
                                          || p_plan_start_date
                                          || ' p_plan_end_date '
                                          || p_plan_end_date);

        select
            sum(
                case
                    when reimbursement_method <> 'To Provider' then
                        check_amount
                    else
                        0
                end
            ),
            sum(
                case
                    when reimbursement_method = 'To Provider' then
                        check_amount
                    else
                        0
                end
            ),
            sum(denied_amount)
        into
            l_part_reim,
            l_provider_pay,
            l_denied_amt
        from
            claim_report_online_v
        where
                entrp_id = p_entrp_id
            and reason_code <> 73
            and product_type = nvl(p_plan_type, product_type)
            and trunc(plan_start_date) >= p_plan_start_date
            and trunc(plan_end_date) <= p_plan_end_date;

   /* For I in (
   select    SUM(CHECK_AMOUNT) OVER () AS total_sal   from CLAIM_REPORT_ONLINE_V
                         where ENTRP_ID = p_entrp_id  ----7898 --- 
                          AND REASON_CODE <> 73
                          and   SERVICE_TYPE   = NVL(p_plan_type,SERVICE_TYPE)
                       and reimbursement_method <> 'To Provider'
                         and   TRUNC(PLAN_START_DATE) >=   p_plan_start_date
                         and   TRUNC(PLAN_END_DATE) <=     p_plan_end_date )
                   ---      and rownum <2) 
                        Loop  
                        l_part_reim := I.total_sal; 
                        End Loop; 

                        For I in (
   select    SUM(CHECK_AMOUNT) OVER () AS total_sal   from CLAIM_REPORT_ONLINE_V
                         where ENTRP_ID = p_entrp_id  ----7898 --- 
                          AND REASON_CODE <> 73
                          and   SERVICE_TYPE   = NVL(p_plan_type,SERVICE_TYPE)
                       and reimbursement_method = 'To Provider'
                         and   TRUNC(PLAN_START_DATE) >=   p_plan_start_date
                         and   TRUNC(PLAN_END_DATE) <=     p_plan_end_date )
                   ---      and rownum <2) 
                        Loop  
                        l_provider_pay := I.total_sal; 
                        End Loop; 
*/
        l_part_reim := nvl(l_part_reim, 0);
        l_provider_pay := nvl(l_provider_pay, 0);
        l_denied_amt := nvl(l_denied_amt, 0);
        l_total_sal := nvl(l_part_reim + l_provider_pay, 0);
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'CLaims_report'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'EMP_ADDR1' value er.address,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'EMP_ADDR2' value er.city
                                                              || ', '
                                                              || er.state
                                                              || ' '
                                                              || er.zip,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'PART_REIM' value '$' || to_char(l_part_reim, 'fm9999G990D00'),
                                        key 'PRO_PAY' value '$' || to_char(l_provider_pay, 'fm9999G990D00'),
                                        key 'TOTAL_SAL' value '$' || to_char(l_total_sal, 'fm9999G990D00'),
                                        key 'DEN_AMT' value '$' || to_char(l_denied_amt, 'fm9999G990D00'),
                                        key 'PLAN_DET' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PLAN_TYPE' value plan_type,
                                                key 'PLAN_DESC' value plan_type_meaning
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select distinct
                                                plan_type,
                                                plan_type_meaning
                                            from
                                                fsa_hra_er_ben_plans_v plans_v
                                            where
                                                plans_v.entrp_id = p_entrp_id
                                        )
                                ),
                                        key 'CLAIMS' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'FIRST_NAME' value first_name,
                                                        key 'LAST_NAME' value last_name,
                                                        key 'DIV_NAME' value division_name,
                                                        key 'CLAIM_NO' value claim_id,
                                                        key 'PAID_DATE' value pay_date,
                                                        key 'CLAIM_AMT' value nvl(claim_amount, 0), -- '$'||TO_CHAR(nvl(CLAIM_AMOUNT,0),'fm9999G990D00'),                                                                    
                                                        key 'APPR_AMT' value nvl(approved_amount, 0),  -- '$'||TO_CHAR(nvl(APPROVED_AMOUNT,0),'fm9999G990D00'),
                                                        key 'PENDED_AMT' value nvl(claim_pending, 0), --  '$'||TO_CHAR(nvl(CLAIM_PENDING,0),'fm9999G990D00'),
                                                        key 'PAID_AMT' value nvl(check_amount, 0), -- '$'||TO_CHAR(nvl(CHECK_AMOUNT,0),'fm9999G990D00'),
                                                        key 'DEN_AMT' value nvl(denied_amount, 0), -- '$'||TO_CHAR(nvl(DENIED_AMOUNT,0),'fm9999G990D00')     ,
                                                        key 'REIM_METHOD' value reimbursement_method,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'CHECK_NUMBER' value check_number,
                                                        key 'TOTAL_SAL' value '$'
                                                                              || to_char(
                                                    nvl(total_sal, 0),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TRANSACTION_NUMBER' value transaction_number,
                                                        key 'DIVISION_CODE' value division_code,
                                                        key 'REASON_CODE' value reason_code,
                                                        key 'PLAN' value service_type,
                                                        key 'SERVICE_TYPE_MEANING' value service_type_meaning,
                                                        key 'PLAN_START_DATE' value plan_start_date,
                                                        key 'PLAN_END_DATE' value plan_end_date
                                            )
                                        returning clob)       
                                                        ---        Key 'SUM_ACC_BALANCE'     Value     '$'||TO_CHAR(sum_Acc_Balance,'fm9999G990D00')              ---- 12 
                                    from
                                        (
                                            (
                                                select
                                                    acc_num,
                                                    transaction_number              claim_id,
                                                    first_name,
                                                    last_name,
                                                    to_char(pay_date, 'mm/dd/yyyy') pay_date,
                                                    approved_amount,
                                                    claim_pending,
                                                    check_amount,
                                                    check_number,
                                                    claim_amount,
                                                    sum(check_amount)
                                                    over()              as total_sal,
                                                    transaction_number,
                                                    reimbursement_method,
                                                    division_code,
                                                    division_name,
                                                    reason_code,
                                                    service_type,
                                                    service_type_meaning,
                                                    denied_amount,
                                                    plan_start_date,
                                                    plan_end_date
                                                from
                                                    claim_report_online_v
                                                where
                                                        entrp_id = p_entrp_id  ----7898 --- 
                                                    and reason_code <> 73
                       ---  and rownum < 501 
                                                    and trunc(plan_start_date) >= p_plan_start_date
                                                    and trunc(plan_end_date) <= p_plan_end_date
                                                    and product_type = nvl(p_plan_type, product_type)
                                                    and service_type = p_service_type 

                         --and  ( DIVISION_CODE IS NULL  OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END)
                                            )
                                            union all
                                            (
                                                select
                                                    c.acc_num,
                                                    b.claim_id,
                                                    first_name,
                                                    last_name,
                                                    null                                         pay_date,
                                                    b.approved_amount,
                                                    b.claim_pending,
                                                    null                                         check_amount,
                                                    null                                         check_number,
                                                    to_number(b.claim_amount)                    claim_amount,
                                                    sum(b.claim_amount)
                                                    over()                           as total_sal,
                                                    b.claim_id                                   transaction_number,
                                                    null                                         reimbursement_method,
                                                    pc_person.get_division_code(b.pers_id)       division_code,
                                                    pc_person.get_division_name(b.pers_id)       division_name,
                                                    0                                            reason_code,
                                                    b.service_type                               service_type,
                                                    pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                                                    b.denied_amount,
                                                    b.plan_start_date,
                                                    b.plan_end_date
                                                from
                                                    payment_register a,
                                                    claimn           b,
                                                    account          c,
                                                    person           e
                                                where
                                                        a.entrp_id = b.entrp_id
                                                    and e.entrp_id = b.entrp_id
                                                    and a.claim_id = b.claim_id
                                                    and e.pers_id = b.pers_id
                                                    and c.pers_id = b.pers_id  ---New
                                                    and b.claim_status = 'DENIED'
                                                    and b.entrp_id = p_entrp_id
                                                    and c.account_type = nvl(p_plan_type, c.account_type)
                   ---    and rownum < 501
                                                    and b.claim_status not in('ERROR', 'CANCELLED')
                                                    and trunc(claim_date) >= p_plan_start_date
                                                    and trunc(claim_date) <= p_plan_end_date
                                                    and b.service_type = p_service_type
                          --and   ( DIVISION_CODE IS NULL OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END)
                                            )
                                        )
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_claims_report := j.files; 
                                ---  l_total_sal := j.CLAIMS.total_sal;
        end loop;

        return l_claims_report;
    end;

    function all_claims_report (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_claim_category  in varchar2 default 'ALL_CLAIMS',
        p_service_type    in varchar2 default 'ALL',
        p_product_type    in varchar2 default 'FSA'
    ) return clob is

        l_claims_report clob;
        l_claim_clob    clob;
        l_part_reim     number;
        l_provider_pay  number;
        l_denied_amt    number;
        l_debit_pay     number;
        l_total_sal     number;
    begin
        pc_log.log_error('All_CLaims_report', 'p_entrp_id '
                                              || p_entrp_id
                                              || ' p_plan_start_date '
                                              || p_plan_start_date
                                              || ' p_plan_end_date '
                                              || p_plan_end_date
                                              || ' p_start_date '
                                              || p_start_date
                                              || ' p_end_date '
                                              || p_end_date
                                              || 'p_claim_category'
                                              || p_claim_category);

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'CLaims_report'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'EMP_ADDR1' value er.address,
                                        key 'EMP_ADDR2' value er.city
                                                              || ', '
                                                              || er.state
                                                              || ' '
                                                              || er.zip,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'ACCOUNT_NUMBER' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'PLAN_DET' value json_query(pc_office_reports.get_plans_json(p_entrp_id, p_plan_start_date
                                        , p_plan_end_date),
           '$' returning clob),
                                        key 'CLAIMS' value json_query(pc_office_reports.get_all_claims_json(p_entrp_id, p_plan_start_date
                                        , p_plan_end_date, p_start_date, p_end_date,
                                                                                                            p_claim_category, p_service_type
                                                                                                            , p_product_type),
           '$' returning clob)
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_claims_report := j.files; 
                                ---  l_total_sal := j.CLAIMS.total_sal;
                --l_CLaims_report := l_claim_clob ; 

        end loop;

        return l_claims_report;
    end;

    function get_enrolle_year_end_letter (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_division_code   in varchar2
    ) return clob is
        l_enrolle_letter clob;
        l_sum_total      number := 0;
        l_name           varchar2(100);
        l_entrp_id       number;
    begin
        begin
            select
                name,
                b.entrp_id
            into
                l_name,
                l_entrp_id
            from
                person     a,
                enterprise b,
                account    c
            where
                    c.acc_num = p_acc_num
                and a.pers_id = c.pers_id
                and a.entrp_id = b.entrp_id;

        exception
            when no_data_found then
                null;
        end;

        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'DEBIT_CARD_SWIPES'
                                             || l_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
										 		--KEY 'ENTRP_NAME' VALUE ER.NAME,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(l_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),   
											 ---   Key 'EMPLOYER_ADDRESS'  Value  PC_ENTRP.GET_CITY(p_entrp_id)   || ',  ' || PC_ENTRP.GET_STATE(p_entrp_id)  , 
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'EE' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value a.acc_num,
                                                        key 'NAME' value name,
                                                        key 'PLAN_TYPE' value plan_type,
                                                        key 'DIV_NAME' value division_name,
                                                        key 'PLAN_YEAR' value to_char(plan_start_date, 'MM/DD/YYYY')
                                                                              || '-'
                                                                              || to_char(plan_end_date, 'MM/DD/YYYY'),
                                                        key 'PHONE' value b.phone_day,
                                                        key 'ADDRESS' value b.address,
                                                        key 'CITY' value b.city,
                                                        key 'STATE' value b.state,
                                                        key 'ZIP' value b.zip,
                                                        key 'Effective_Date' value b.hire_date,
                                                        key 'ZIP' value b.zip,
                                                        key 'TERM_DATE' value decode(termination_date, null, 'NA', termination_date),
                                                        key 'START_DATE' value plan_start_date,
                                                        key 'END_DATE' value plan_end_date,
                                                        key 'EFF_DATE' value b.hire_date,
                                                        key 'DEPOSIT' value '$'
                                                                            || to_char(
                                                    nvl(
                                                        pc_fin.contribution_ytd(acc_id, account_type, plan_type, plan_start_date, plan_end_date
                                                        ),
                                                        0
                                                    ),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'DISBURSEMENT' value '$'
                                                                                 || to_char(
                                                    nvl(
                                                        pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, plan_start_date
                                                        ,
                                                                                plan_end_date),
                                                        0
                                                    ),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'ACC_BALANCE' value '$'
                                                                                || to_char(
                                                    nvl(
                                                        pc_account.acc_balance(acc_id, plan_start_date, plan_end_date, 'FSA', plan_type
                                                        ,
                                                                               plan_start_date, plan_end_date),
                                                        0
                                                    ),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'ANNUAL_ELECTION' value '$' || to_char(annual_election, 'fm9999G990D00')  
                                      ---  	Key 'CLAIM_AMT' Value '$'||TO_CHAR(CLAIM_AMOUNT,'fm9999G990D00')      	 			, 				
                                            )
                                        returning clob)
                                    from
                                        fsa_hra_employees_v a,
                                        person              b
                                    where
                                            a.pers_id = b.pers_id
                                        and acc_num = p_acc_num
                                        and plan_start_date = p_plan_start_date
                                        and plan_end_date = p_plan_end_date
                                        and a.plan_type = 'FSA'
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = l_entrp_id
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_enrolle_letter := x.files;
        end loop;

        return l_enrolle_letter;
    end get_enrolle_year_end_letter;

    function get_enrolle_account_balance (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob is
        l_enrolle_account_bal clob;
        l_division_code       varchar2(10);
        v_sum_rollover        number;
    begin
        pc_log.log_error('get_Enrolle_Account_balance', 'p_plan_type '
                                                        || p_plan_type
                                                        || ' p_entrp_id '
                                                        || p_entrp_id
                                                        || ' p_plan_start_date '
                                                        || p_plan_start_date
                                                        || ' p_plan_end_date '
                                                        || p_plan_end_date
                                                        || ' p_division_code '
                                                        || p_division_code);

/* hari not required below code sum calculated in word or excel templates 
      SELECT sum(nvl(Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,P_Plan_Start_Date,P_Plan_End_Date),0)) 
        into v_sum_Rollover
        FROM FSA_HRA_EMPLOYEES_V
        WHERE entrp_id =  P_Entrp_Id  
        AND   status NOT IN ('P', 'R' )
        AND Plan_Type =  nvl(p_plan_type, Plan_Type) 
        AND   PLAN_START_DATE = p_Plan_start_date
        AND   PLAN_END_DATE  =  p_Plan_end_date;
*/

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Enrolle_Account-'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'EMP_ADDR1' value er.address,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'EMP_ADDR2' value er.city
                                                              || ', '
                                                              || er.state
                                                              || ' '
                                                              || er.zip,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'STMT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'RNO' value rno,
                                                        key 'ACC_NUM' value acc_num,
                                                        key 'FIRST_NAME' value first_name,
                                                        key 'LAST_NAME' value last_name,
                                                        key 'DIV_NAME' value division_name,
                                                        key 'EFFEC_DATE' value effective_date,
                                                        key 'PLAN_TYPE' value plan_type,
                                                        key 'PLAN_NAME' value plan_type_meaning,
                                                        key 'TERM_DATE' value termination_date,
                                                        key 'ORIG_ELEC' value nvl(original_elections, 0.00),
                                                        key 'ROLLOVER' value nvl(rollover, 0.00),
                                                        key 'ANN_ELE' value nvl(annual_election, 0.00),
                                                        key 'AN_PLUS_ROLL' value nvl(annual_election, 0.00) + nvl(rollover, 0.00),
                                                        key 'CONT_YTD' value nvl(contribution_ytd, 0.00),
                                                        key 'CLAIMS_YTD' value nvl(claims_ytd, 0.00),
                                                        key 'FOR_BAL' value nvl(forfeiture_balance, 0.00),
                                                        key 'AVAIL_BAL' value nvl(acc_balance, 0.00),
                                                        key 'SUM_ANNUAL_ELECTION' value '$'
                                                                                        || to_char(
                                                    nvl(sum_annual_election, 0.00),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'SUM_ACC_BALANCE' value '$'
                                                                                    || to_char(
                                                    nvl(sum_acc_balance, 0.00),
                                                    'fm9999G990D00'
                                                )
                                            )
                                        returning clob)
                                    from
                                        (
                                            select
                                                acc_num,         --- 1 
                                                row_number()
                                                over(
                                                            order by
                                                                entrp_id asc
                                                )                                                                                              rno
                                                ,
                                                first_name,
                                                last_name,
                                                division_name,       --- 3 
                                                to_char(start_date, 'MM/DD/YYYY')                                                                      effective_date
                                                ,
                                                plan_type,
                                                plan_type_meaning,
                                                to_char(
                                                            trunc(termination_date),
                                                            'MM/DD/YYYY'
                                                        )                                                                                              termination_date
                                                        ,     --- 4 
                                                to_char(
                                                            trunc(p_plan_start_date),
                                                            'MM/DD/YYYY'
                                                        )                                                                                              plan_start_date
                                                        ,    --- 5 
                                                annual_election - pc_benefit_plans.get_rollover(acc_id, plan_type, p_plan_start_date,
                                                p_plan_end_date) original_elections,     --- 6
                                                pc_benefit_plans.get_rollover(acc_id, plan_type, p_plan_start_date, p_plan_end_date)                   rollover
                                                ,   --- 7
																			-- To_Char(ANNUAL_ELECTION) Annual_Election,     ---- 8 
                                                annual_election                                                                                        annual_election
                                                ,     ---- 8 
                                                pc_fin.contribution_ytd(acc_id, account_type, plan_type, p_plan_start_date, p_plan_end_date
                                                )           contribution_ytd,     -----9 

                                                pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, p_plan_start_date,
                                                                        p_plan_end_date)                                                                                       claims_ytd
                                                                        ,            --- 10  

                                                pc_fin.contribution_ytd(acc_id, account_type, plan_type, p_plan_start_date, p_plan_end_date
                                                ) - pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, p_plan_start_date,
                                                                                                                                           p_plan_end_date
                                                                                                                                           )                                                                                       forfeiture_balance
                                                                                                                                           ,     --- 11 

                                                pc_account.current_hrafsa_balance(acc_id, null, null, plan_start_date, plan_end_date,
                                                                                  plan_type)                                                                                             acc_balance
                                                                                  ,
                                                sum(pc_account.current_hrafsa_balance(acc_id, null, null, plan_start_date, plan_end_date
                                                ,
                                                                                      plan_type))
                                                over(partition by entrp_id)                                                                    as
                                                sum_acc_balance,
                                                sum(annual_election)
                                                over(partition by entrp_id)                                                                    as
                                                sum_annual_election
                                            from
                                                fsa_hra_employees_v
                                            where
                                                    entrp_id = p_entrp_id
                                                and status not in('P', 'R')
                                                and plan_type = nvl(p_plan_type, plan_type) 
                                                     ----  AND rownum <  500
                                                and plan_start_date = p_plan_start_date
                                                and plan_end_date = p_plan_end_date
                                            order by
                                                entrp_id
                                        )
                                ) 
                                        /* not required below code since sum calculated in word or excel templates 
                                    	KEY 'ENROLLE_SUM' VALUE 
											  	(SELECT  json_arrayagg ( JSON_OBJECT( 
                                            Key 'S_ORI_ELE'         Value     '$'||TO_CHAR(nvl(sum_Original_Elections,0),'fm9999G990D00'),       ----1
                                            Key 'S_ROLL'            Value     '$'|| TO_CHAR(nvl(v_sum_Rollover,0),'fm9999G990D00'),               -----2  
                                            Key 'S_ANN_ELEC'        Value     '$'||TO_CHAR(nvl(sum_ANNUAL_ELECTION,0),'fm9999G990D00'),         ---- 3
                                            Key 'S_CON_YTD'      Value     '$'||TO_CHAR(nvl(Sum_Contr_Ytd,0),'fm9999G990D00'),               -----4
                                            Key 'S_CLA_YTD'          Value     '$'||TO_CHAR(nvl(sum_Claims_Ytd,0),'fm9999G990D00'),              ---- 5
                                            Key 'S_FORF_BAL'        Value     '$'||TO_CHAR(nvl(Sum_Forf_Bal,0),'fm9999G990D00'),                 --- 6
                                            Key 'S_ACC_BAL'         Value     '$'||TO_CHAR(nvl(sum_Acc_Balance,0),'fm9999G990D00')              ---- 7
																)returning clob)
                                                        FROM   ( 
																SELECT  
																			entrp_id ,         --- 1 
    																		sum(Annual_Election  -  Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,P_Plan_Start_Date,P_Plan_End_Date))  sum_Original_Elections,     --- 6
																			Sum(Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,P_Plan_Start_Date,P_Plan_End_Date)) Sum_Rollover,   --- 7
																			sum(PC_FIN.CONTRIBUTION_YTD(ACC_ID, Account_Type,Plan_Type
																			,p_Plan_start_date
																			,p_Plan_end_date) )  Sum_Contr_Ytd  ,     -----9 
																			SUm(Pc_Fin.Disbursement_Ytd(Acc_Id, Account_Type, Plan_Type,Null
																			, p_Plan_start_date, p_Plan_end_date))  sum_Claims_Ytd,            --- 10  
																			sum(PC_FIN.CONTRIBUTION_YTD(Acc_Id, Account_Type,Plan_Type
																			,p_Plan_start_date
																			,p_Plan_end_date)  
																			-
																			PC_FIN.disbursement_YTD(Acc_Id, Account_Type,Plan_Type,null
																			,    p_Plan_start_date  ,   
																			p_Plan_end_date ))     Sum_Forf_Bal  ,     --- 11 
																		    sum(PC_ACCOUNT.current_hrafsa_balance(
																			ACC_ID, null, null,Plan_start_date,Plan_end_date 
																			,PLAN_TYPE) )   sum_Acc_Balance,
                                                                            sum(ANNUAL_ELECTION )  sum_ANNUAL_ELECTION
                                                     FROM FSA_HRA_EMPLOYEES_V
                                                        WHERE entrp_id =  P_Entrp_Id  
                                                     AND   status NOT IN ('P', 'R' )
                                                     AND Plan_Type =  nvl(p_plan_type, Plan_Type) 
                                            ----        AND rownum <  1000
                                                       AND   PLAN_START_DATE = p_Plan_start_date
                                                       AND   PLAN_END_DATE  =  p_Plan_end_date    
													   Group by  entrp_id))  
                                                       */
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_enrolle_account_bal := j.files;
        end loop;
        ---db_tool( 'text 1 : ' || substr(l_Enrolle_Account_bal,1, 3980)); 
        return l_enrolle_account_bal;
    end;

    function get_fsa_balance_register (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_product_type    in varchar2
    ) return clob is

        l_balance_register clob;
        l_sum_total        number := 0;
        l_name             varchar2(100);
        l_count            number := 0;
        l_entrp_id         number;
    begin
        pc_log.log_error('get_er_recon_report', 'P_END_DATE ' || p_plan_end_date);
 ----  pc_log.log_error('get_er_recon_report','P_PRODUCT_TYPE '||P_PRODUCT_TYPE);
        pc_log.log_error('get_er_recon_report', 'p_entrp_id ' || p_entrp_id);

   -- EXECUTE IMMEDIATE 'Truncate Table  FSAHRA_ER_BALANCE_GTT'; 

  -- EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
        insert_er_balance_gtt(p_entrp_id, p_product_type, p_plan_end_date);
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'FSA_BALANCE_REGISTER'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'ACC_TYPE' value p_product_type,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id), 
										---		KEY 'START_DATE' VALUE   To_Char(p_Plan_start_date, 'MM/DD/YYYY') , 
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),   
											 ---   Key 'EMPLOYER_ADDRESS'  Value  PC_ENTRP.GET_CITY(p_entrp_id)   || ',  ' || PC_ENTRP.GET_STATE(p_entrp_id)  , 
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'STMT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'TR_TYPE' value transaction_type,
                                                        key 'CLAIM_NO' value claim_invoice_id,
                                                        key 'CHECK_AMT' value nvl(check_amount, 0),
                                                        key 'PLAN_TYPE' value plan_type,
                                                        key 'REASON_CODE' value reason_code,
                                                        key 'NOTE' value note,
                                                        key 'TR_DATE' value to_char(transaction_date, 'MM/DD/YYYY'),
                                                        key 'PAID_DATE' value to_char(paid_date, 'MM/DD/YYYY'),
                                                        key 'FIRST_NAME' value first_name,
                                                        key 'LAST_NAME' value last_name,
                                                        key 'ORD_NO' value ord_no,
                                                        key 'ER_PAY_ID' value employer_payment_id,
                                      --   Key 'ACC_BALANCE' Value  '$'||TO_CHAR(NVL(PC_ACCOUNT.acc_balance(
                                      --        ACC_ID,p_Plan_start_date, p_Plan_end_date ,'FSA',PLAN_TYPE,p_Plan_start_date, p_Plan_end_date),0), 'fm9999G990D00') 
                                                        key 'ACC_BALANCE' value nvl(
                                                    pc_account.acc_balance(acc_id, p_plan_start_date, p_plan_end_date, 'FSA', plan_type
                                                    ,
                                                                           p_plan_start_date, p_plan_end_date),
                                                    0
                                                )
                                            )
                                        returning clob)
                                    from
                                        fsahra_er_balance_gtt
                              ----          where rownum < 101
                                    where
                                        acc_num <> '-'
                                        ---  order by paid_date desc
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_balance_register := x.files;
        end loop;

        return l_balance_register;
    end get_fsa_balance_register;

    function get_all_claims_json (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_claim_category  in varchar2 default 'ALL_CLAIMS',
        p_service_type    in varchar2 default 'ALL',
        p_product_type    in varchar2 default 'FSA'
    ) return clob is
        l_claim_clob clob;
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'ACC_NUM' value acc_num,
                                key 'FIRST_NAME' value first_name,
                                key 'LAST_NAME' value last_name,
                                key 'EMP_NAME' value first_name
                                                     || ' '
                                                     || last_name,
                                key 'DIV_NAME' value division_name,
                                key 'CLAIM_NO' value claim_id,
                                key 'PAID_DATE' value pay_date,
                                key 'CLAIM_AMT' value nvl(claim_amount, 0),
                                key 'APPR_AMT' value nvl(approved_amount, 0),
                                key 'PENDED_AMT' value nvl(claim_pending, 0),
                                key 'PAID_AMT' value nvl(check_amount, 0),
                                key 'DEN_AMT' value nvl(denied_amount, 0),
                                key 'PLAN_YEAR' value to_char(plan_start_date, 'MM/DD/YYYY')
                                                      || '-'
                                                      || to_char(plan_end_date, 'MM/DD/YYYY'),
                                key 'REIM_METHOD' value reimbursement_method,
                                key 'CHECK_AMOUNT' value check_amount,
                                key 'EMP_NAME' value first_name
                                                     || ' '
                                                     || last_name,
                                key 'TRANSACTION_NUMBER' value transaction_number,
                                key 'DIVISION_CODE' value division_code,
                                key 'REASON_CODE' value reason_code,
                                key 'SER_TYPE' value service_type,
                                key 'SERVICE_TYPE_MEANING' value service_type_meaning,
                                key 'PLAN_START_DATE' value to_char(plan_start_date, 'MM/DD/YYYY'),
                                key 'PLAN_END_DATE' value to_char(plan_end_date, 'MM/DD/YYYY'),
                                key 'CLAIM_DATE' value to_char(claim_date, 'MM/DD/YYYY'),
                                key 'OFF_AMT' value nvl(off_amt, 0),
                                key 'SUBS' value decode(
                            nvl(substantiated, 'Y'),
                            'Y',
                            'No',
                            'Yes'
                        )
                    returning clob)
                returning clob) claims      
---        Key 'SUM_ACC_BALANCE'     Value     '$'||TO_CHAR(sum_Acc_Balance,'fm9999G990D00')              ---- 12 
            from
                (
                    select
                        *
                    from
                        all_claims_v
                    where
                            entrp_id = p_entrp_id
                        and plan_start_date = p_plan_start_date
                        and plan_end_date = p_plan_end_date
                        and paid_date between p_start_date and p_end_date
                        and service_type = case
                                               when p_service_type = 'ALL' then
                                                   service_type
                                               else
                                                   p_service_type
                                           end
                        and claim_category = case
                                                 when p_claim_category = 'ALL_CLAIMS' then
                                                     claim_category
                                                 else
                                                     p_claim_category
                                             end
                        and product_type = p_product_type
                )
        ) loop
            l_claim_clob := x.claims;
        end loop;

        return l_claim_clob;
    end get_all_claims_json;

    function get_plans_json (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is
        l_plan_json clob;
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'PLAN_TYPE' value plan_type,
                        key 'PLAN_DESC' value plan_type_meaning
                    returning clob)
                returning clob) plans
            from
                (
                    select distinct
                        plan_type,
                        plan_type_meaning
                    from
                        fsa_hra_er_ben_plans_v plans_v
                    where
                            plans_v.entrp_id = p_entrp_id
                        and plans_v.plan_start_date = p_plan_start_date
                        and plans_v.plan_end_date = p_plan_end_date
                )
        ) loop
            l_plan_json := x.plans;
        end loop;

        return l_plan_json;
    end get_plans_json;

-- VANITHA TO HARI : IF NOT USED REMOVE IT 
    function get_all_claims (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_report_type     in varchar2
    ) return clob is
        l_claim_clob clob;
    begin
        if p_report_type = 'ALL_CLAIMS_REPORT' then
            for x in (
                select
                    json_arrayagg(
                        json_object(
                            key 'filename' value 'get_Claims'
                                                 || p_entrp_id
                                                 || '.pdf',
                                    key 'data' value json_arrayagg(
                                    json_object(
                                    key 'ACC_NUM' value acc_num,
                                            key 'FIRST_NAME' value first_name,
                                            key 'LAST_NAME' value last_name,
                                            key 'PAY_DATE' value to_char(pay_date, 'mm/dd/yyyy'),
                                            key 'APPROVED_AMOUNT' value approved_amount,
                                            key 'CLAIM_PENDING' value claim_pending,
                                            key 'CHECK_AMOUNT' value check_amount,
                                            key 'CHECK_NUMBER' value check_number,
                                            key 'CLAIM_AMOUNT' value to_number(claim_amount),
                                            key 'TRANSACTION_NUMBER' value transaction_number,
                                            key 'REIMBURSEMENT_METHOD' value reimbursement_method,
                                            key 'REASON_CODE' value reason_code,
                                            key 'SERVICE_TYPE_MEANING' value service_type_meaning,
                                            key 'PLAN_YEAR' value to_char(plan_start_date, 'MM/DD/YYYY')
                                                                  || '-'
                                                                  || to_char(plan_end_date, 'MM/DD/YYYY'),
                                            key 'PLAN_TYPE' value service_type,
                                            key 'DIVISION_NAME' value division_name,
                                            key 'DIVISION_CODE' value division_code,
                                            key 'DENIED_AMOUNT' value denied_amount,
                                            key 'PLAN_START_DATE' value plan_start_date,
                                            key 'PLAN_END_DATE' value plan_end_date,
                                            key 'CLAIM_DATE' value to_char(transaction_date, 'mm/dd/yyyy'),
                                            key 'SUBSTANTIATED' value 'Yes',
                                            key 'REMAINING_OFFSET_AMT' value pc_claim.get_remaining_offset(transaction_number)
                                returning clob)
                            returning clob)
                        returning clob)
                    ) files
                from
                    claim_report_online_v
                where
                        entrp_id = p_entrp_id
                    and reason_code <> 73
                    and trunc(pay_date) >= p_plan_start_date
                    and trunc(pay_date) <= p_plan_end_date
	               --  and   ( DIVISION_CODE IS NULL
	              ---           OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END)
                union all
                select
                    json_arrayagg(
                        json_object(
                            key 'filename' value 'get_Claims'
                                                 || p_entrp_id
                                                 || '.pdf',
                                    key 'data' value json_arrayagg(
                                    json_object(
                                    key 'ACC_NUM' value acc_num,
                                            key 'FIRST_NAME' value first_name,
                                            key 'LAST_NAME' value last_name,
                                            key 'PAY_DATE' value null,
                                            key 'APPROVED_AMOUNT' value approved_amount,
                                            key 'CLAIM_PENDING' value claim_pending,
                                            key 'CHECK_AMOUNT' value check_amount,
                                            key 'CHECK_NUMBER' value null,
                                            key 'CLAIM_AMOUNT' value to_number(claim_amount),
                                            key 'TRANSACTION_NUMBER' value claim_id,
                                            key 'REIMBURSEMENT_METHOD' value pc_lookups.get_reason_name(reason_code),
                                            key 'REASON_CODE' value to_char(reason_code),
                                            key 'SERVICE_TYPE_MEANING' value service_type_meaning,
                                            key 'PLAN_YEAR' value to_char(plan_start_date, 'MM/DD/YYYY')
                                                                  || '-'
                                                                  || to_char(plan_end_date, 'MM/DD/YYYY'),
                                            key 'PLAN_TYPE' value service_type,
                                            key 'DIVISION_NAME' value division_name,
                                            key 'DIVISION_CODE' value division_code,
                                            key 'DENIED_AMOUNT' value denied_amount,
                                            key 'PLAN_START_DATE' value plan_start_date,
                                            key 'PLAN_END_DATE' value plan_end_date,
                                            key 'CLAIM_DATE' value to_char(claim_date, 'mm/dd/yyyy'),
                                            key 'SUBSTANTIATED' value decode(
                                        nvl(substantiated, 'Y'),
                                        'Y',
                                        'Yes',
                                        'No'
                                    ),
                                            key 'REMAINING_OFFSET_AMT' value decode(
                                        nvl(substantiated, 'Y'),
                                        'Y',
                                        pc_claim.get_remaining_offset(claim_id),
                                        'Yes',
                                        pc_claim.get_remaining_offset(claim_id)
                                    )
                                returning clob)
                            returning clob)
                        returning clob)
                    ) files
                from
                    hrafsa_debit_card_claims_v
                where
                        entrp_id = p_entrp_id
                    and trunc(claim_date) >= p_plan_start_date
                    and trunc(claim_date) <= p_plan_end_date
	             --      and   ( DIVISION_CODE IS NULL
	                  --       OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END)
	                 /* Added for Ticket 3674*/
                union all
                select
                    json_arrayagg(
                        json_object(
                            key 'filename' value 'get_Claims'
                                                 || p_entrp_id
                                                 || '.pdf',
                                    key 'data' value json_arrayagg(
                                    json_object(
                                    key 'ACC_NUM' value c.acc_num,
                                            key 'FIRST_NAME' value first_name,
                                            key 'LAST_NAME' value last_name,
                                            key 'PAY_DATE' value null,
                                            key 'APPROVED_AMOUNT' value b.approved_amount,
                                            key 'CLAIM_PENDING' value b.claim_pending,
                                            key 'CHECK_AMOUNT' value null,
                                            key 'CHECK_NUMBER' value null,
                                            key 'CLAIM_AMOUNT' value to_number(b.claim_amount),
                                            key 'TRANSACTION_NUMBER' value b.claim_id,
                                            key 'REIMBURSEMENT_METHOD' value null,
                                            key 'REASON_CODE' value '0',
                                            key 'SERVICE_TYPE_MEANING' value pc_lookups.get_fsa_plan_type(b.service_type),
                                            key 'PLAN_YEAR' value to_char(b.plan_start_date, 'MM/DD/YYYY')
                                                                  || '-'
                                                                  || to_char(b.plan_end_date, 'MM/DD/YYYY'),
                                            key 'PLAN_TYPE' value b.service_type,
                                            key 'DIVISION_NAME' value pc_person.get_division_name(b.pers_id),
                                            key 'DIVISION_CODE' value pc_person.get_division_code(b.pers_id),
                                            key 'DENIED_AMOUNT' value b.denied_amount,
                                            key 'PLAN_START_DATE' value b.plan_start_date,
                                            key 'PLAN_END_DATE' value b.plan_end_date,
                                            key 'CLAIM_DATE' value to_char(b.claim_date, 'mm/dd/yyyy'),
                                            key 'SUBSTANTIATED' value 'Yes'
                                returning clob)
                            returning clob)
                        returning clob)
                    ) files
                from
                    payment_register a,
                    claimn           b,
                    account          c,
                    person           e
                where
                        a.entrp_id = b.entrp_id
                    and e.entrp_id = b.entrp_id
                    and a.claim_id = b.claim_id
                    and e.pers_id = b.pers_id
                    and c.pers_id = b.pers_id
                    and b.claim_status = 'DENIED'
                    and b.entrp_id = p_entrp_id
                    and b.claim_status not in ( 'ERROR', 'CANCELLED' )
                    and trunc(claim_date) >= p_plan_start_date
                    and trunc(claim_date) <= p_plan_end_date
            ) loop
                l_claim_clob := x.files;
            end loop;
        end if;

        if p_report_type = 'DEBIT_CARD_CLAIMS' then
            for x in (
                select
                    json_arrayagg(
                        json_object(
                            key 'filename' value 'get_Claims'
                                                 || p_entrp_id
                                                 || '.pdf',
                                    key 'data' value json_arrayagg(
                                    json_object(
                                    key 'ACC_NUM' value acc_num,
                                            key 'FIRST_NAME' value first_name,
                                            key 'LAST_NAME' value last_name,
                                            key 'PAY_DATE' value to_char(paid_date, 'mm/dd/yyyy'),
                                            key 'CLAIM_AMOUNT' value claim_amount,
                                            key 'APPROVED_AMOUNT' value approved_amount,
                                            key 'CLAIM_PENDING' value claim_pending,
                                            key 'DEDUCTIBLE_AMOUNT' value deductible_amount,
                                            key 'CHECK_AMOUNT' value check_amount,
                                            key 'CLAIM_ID' value claim_id,
                                            key 'DIVISION_CODE' value division_code,
                                            key 'DIVISION_NAME' value division_name,
                                            key 'PROVIDER_NAME' value provider_name,
                                            key 'SERVICE_TYPE' value service_type,
                                            key 'SERVICE_TYPE_MEANING' value service_type_meaning,
                                            key 'DENIED_AMOUNT' value denied_amount,
                                            key 'PLAN_START_DATE' value plan_start_date,
                                            key 'PLAN_END_DATE' value plan_end_date,
                                            key 'CLAIM_DATE' value to_char(claim_date, 'mm/dd/yyyy'),
                                            key 'SUBSTANTIATED' value decode(
                                        nvl(substantiated, 'Y'),
                                        'Y',
                                        'No',
                                        'Yes'
                                    ),  --(From view it comes as Unsubstatiated.Hence while decoding the meaning gets reversed)
                                            key 'AMOUNT_REMAINING_FOR_OFFSET' value amount_remaining_for_offset
                                returning clob)
                            returning clob)
                        returning clob)
                    ) files
                from
                    hrafsa_debit_card_claims_v
                where
                        entrp_id = p_entrp_id
                    and reason_code in ( 13, 121 ) -- Added by Joshi for ticket 11232 
                    and trunc(plan_start_date) >= p_plan_start_date
                    and trunc(plan_end_date) <= p_plan_end_date
            )
               --   and   ( DIVISION_CODE IS NULL
                ---        OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END))
             loop
                l_claim_clob := x.files;
            end loop;

        end if;

    end get_all_claims;

 ------  21/06/2023

    function get_employee_info (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return clob is
        l_ee_web  clob;
        l_acc_num varchar2(100);
    begin
        begin
            select
                acc_num
            into l_acc_num
            from
                account a
            where
                entrp_id = p_entrp_id;

        exception
            when no_data_found then
                null;
        end;

        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'get_EMPLOYEE_Info'
                                             || l_acc_num
                                             || '.pdf',
                                key 'ADDRESS' value pc_web_utility_pkg.get_sterling_address1,
                                key 'CITY' value pc_web_utility_pkg.get_sterling_city,
                                key 'STATE' value pc_web_utility_pkg.get_sterling_state,
                                key 'ZIP' value pc_web_utility_pkg.get_sterling_zip,
                                key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'ER_NAME' value e.name,
                                                key 'ACC_NUM' value ac.acc_num,
                                                key 'ER_ACC_NUM' value l_acc_num,
                                                key 'NAME' value p.first_name
                                                                 || ' '
                                                                 || last_name,
                                                key 'ACC_ID' value ac.acc_id,
                                                key 'PERS_ID' value p.pers_id,
                                                key 'ER_NAME' value e.name,
                                                key 'HIRE_DATE' value p.hire_date,
                                                key 'DIVISION_CODE' value pc_person.get_division_name(p.pers_id)
                                    )
                                returning clob)
                            from
                                person     p,
                                enterprise e,
                                account    ac
                            where
                                    ac.pers_id = p.pers_id
                                and p.entrp_id = e.entrp_id
                                and p.entrp_id = nvl(p_entrp_id, p.entrp_id)
                                and(p.division_code is null
                                    or p.division_code = decode(p_division_code, 'ALL_DIVISION', p.division_code, p_division_code)
                                    or p_division_code is null)
                                    ----  AND    AC.ACCOUNT_TYPE IN ('HRA','FSA')  
                        )
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    ac.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
        )
               ---               GROUP BY ER.ENTRP_ID ,AC.ACC_NUM )
         loop
            l_ee_web := x.files;
        end loop;

        return l_ee_web;
    end get_employee_info;

    function get_5498_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return clob is
        l_5498_web clob;
        l_count    number;
        l_entrp_id number;
        l_acc_num  varchar2(30);
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value '5498_'
                                             || p_acc_num
                                             || '.pdf',
                                key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'NAME' value first_name
                                                         || ' '
                                                         || last_name,  ---  nvl(  strip_bad(B.FIRST_NAME) ,'')||' '||nvl(strip_bad(B.MIDDLE_NAME) ,'')||' '||nvl(strip_bad(B.LAST_NAME),'') , 
                                                key 'ADDRESS' value b.address,
                                                key 'CITY' value b.city,
                                                key 'STATE' value b.state,  ---p_acc_num
                                                key 'ZIP' value zip,
                                                key 'ACC_NUM' value p_acc_num,   
                                        --Key 'ER_EIN' Value  ER.ENTRP_CODE, 
                                                key 'SSN' value '***-**-'
                                                                || substr(b.ssn, 8, 4),    
                                      --  Key 'ER_ACC_NUM' Value  l_acc_num,  
                                                key 'YEAR' value p_year,
                                                key 'BOX1' value format_money(0),
                                                key 'BOX2' value format_money(nvl(
                                            case
                                                when a.curr_yr_deposit < 0 then
                                                    0
                                                else a.curr_yr_deposit
                                            end, 0)),
                                                key 'BOX3' value format_money(nvl(
                                            case
                                                when a.prev_yr_deposit < 0 then
                                                    0
                                                else a.prev_yr_deposit
                                            end, 0)),
                                                key 'BOX4' value format_money(nvl(
                                            case
                                                when a.rollover < 0 then
                                                    0
                                                else a.rollover
                                            end, 0)),
                                                key 'BOX5' value format_money(nvl(
                                            case
                                                when a.current_bal < 0 then
                                                    0
                                                else a.current_bal
                                            end, 0)),
                                                key 'SADDRESS' value pc_web_utility_pkg.get_sterling_address1,
                                      --      KEY 'SNAME' value     PC_ENTRP.get_entrp_name(b.entrp_id) , 
                                                key 'SCITY' value pc_web_utility_pkg.get_sterling_city,
                                                key 'SSTATE' value pc_web_utility_pkg.get_sterling_state,
                                                key 'SZIP' value pc_web_utility_pkg.get_sterling_zip,
                                      --  Key 'SSN' Value '***-**-'||SUBSTR(B.SSN,8,4) , 
                                                key 'GROSS_DIST' value format_money(a.gross_dist),
                                                key 'EARN_ON_EXCESS' value format_money(0.00),
                                                key 'FMV_ON_DOD' value format_money(0.00),
                                                key 'CORRECTED_FLAG' value a.corrected_flag
                                    )
                                returning clob)
                            from
                                tax_forms a,
                                person    b
                            where
                                    a.pers_id = b.pers_id
                                and a.tax_doc_type = '5498'
                                and a.acc_num = p_acc_num
                                and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
                                and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
                                and a.batch_number in(
                                    select
                                        max(batch_number)
                                    from
                                        tax_forms
                                    where
                                            a.tax_doc_type = tax_forms.tax_doc_type
                                        and a.acc_num = tax_forms.acc_num
                                        and begin_date = a.begin_date
                                        and end_date = a.end_date
                                )
                        )
                    returning clob)
                returning clob) files
            from
                dual
        ) loop
            l_5498_web := x.files;
        end loop;

        return l_5498_web;
    end;
    /*

----------   07/04/2023 rprabu 
   FUNCTION get_5498_web
   (p_acc_num    IN VARCHAR2
   ,p_year     IN VARCHAR2)
    RETURN cLOB  is 
    l_5498_web  CLOB; 
    Begin

     FOR X IN(SELECT json_arrayagg(
                           json_object(
                            KEY 'filename' value 'GET_dependent_'||p_acc_num||'.pdf',
                                           KEY 'ADDRESS'  value   pc_web_utility_pkg.get_sterling_address1 , 
                                           KEY 'CITY' value     pc_web_utility_pkg.get_sterling_city ,
                                           KEY 'STATE' value     pc_web_utility_pkg.get_sterling_state ,
                                           KEY 'ZIP' value    pc_web_utility_pkg.get_sterling_zip ,
                         KEY 'data' VALUE  (SELECT  json_arrayagg ( JSON_OBJECT( 
                                        Key 'NAME' Value    nvl(  strip_bad(B.FIRST_NAME) ,'')||' '||nvl(strip_bad(B.MIDDLE_NAME) ,'')||' '||nvl(strip_bad(B.LAST_NAME),'') , 
                                        Key 'ADDRESS' Value b.ADDRESS , 
                                        Key 'CITY' Value  B.CITY , 
                                        Key 'STATE' Value  B.STATE, 
                                        Key 'ZIP' Value ZIP , 
                                        Key 'SSN' Value '***-**-'||SUBSTR(B.SSN,8,4) , 
                                        Key 'GROSS_DIST' Value FORMAT_MONEY(A.GROSS_DIST) , 
                                        Key 'EARN_ON_EXCESS' Value  FORMAT_MONEY(0.00) , 
                                        Key 'FMV_ON_DOD' Value  FORMAT_MONEY(0.00), 
                                        Key 'CORRECTED_FLAG' Value  A.CORRECTED_FLAG  
                                                      )returning clob)
					FROM TAX_FORMS A, PERSON B
					WHERE A.PERS_ID = B.PERS_ID
				      AND   A.TAX_DOC_TYPE = '1099'
                      AND   A.acc_num = p_acc_num
                      AND   A.BEGIN_DATE = TO_DATE('01-JAN-'||p_year,'DD-MON-YYYY')
                      AND   A.END_DATE = TO_DATE('31-DEC-'||p_year,'DD-MON-YYYY')
                      AND   A.BATCH_NUMBER IN ( SELECT MAX(BATCH_NUMBER)   
                                                  FROM  TAX_FORMS
                                                  where   A.TAX_DOC_TYPE = TAX_FORMS.TAX_DOC_TYPE
                                                  AND A.ACC_NUM = TAX_FORMS.ACC_NUM
                                                  and BEGIN_DATE = A.BEGIN_DATE
                                                   AND END_DATE = A.END_DATE))
                                returning clob)returning clob)   files
                              FROM ENTERPRISE ER, ACCOUNT AC
                              WHERE AC.ENTRP_ID =  p_acc_num  
                                     AND   ER.ENTRP_ID = AC.ENTRP_ID
                                     AND   AC.ACCOUNT_STATUS = 1
                              GROUP BY ER.ENTRP_ID ,AC.ACC_NUM )
                             Loop
                                  l_5498_web := X.files ; 
                                End Loop;

    end; 

 */
----------   07/04/2023 rprabu 
    function get_1099_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return clob is
        l_1099_web clob;
        l_entrp_id varchar2(50);
        l_acc_num  varchar2(50);
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value '1099_'
                                             || p_acc_num
                                             || '.pdf',
                                key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'NAME' value nvl(
                                            strip_bad(b.first_name),
                                            ''
                                        )
                                                         || ' '
                                                         || nvl(
                                            strip_bad(b.middle_name),
                                            ''
                                        )
                                                         || ' '
                                                         || nvl(
                                            strip_bad(b.last_name),
                                            ''
                                        ),
                                                key 'ADDRESS' value b.address,
                                                key 'CITY' value b.city,
                                                key 'STATE' value b.state,
                                                key 'ZIP' value zip,
                                                key 'YEAR' value p_year,
                                                key 'ACC_NUM' value p_acc_num,
                                                key 'SSN' value '***-**-'
                                                                || substr(b.ssn, 8, 4),
                                                key 'GROSS_DIST' value format_money(a.gross_dist),
                                                key 'EARN_ON_EXCESS' value format_money(0.00),
                                                key 'FMV_ON_DOD' value format_money(0.00),
                                                key 'CORRECTED_FLAG' value a.corrected_flag
                                    returning clob)
                                returning clob)
                            from
                                tax_forms a,
                                person    b
                            where
                                    a.pers_id = b.pers_id
                                and a.tax_doc_type = '1099'
                                and a.acc_num = p_acc_num
                                and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
                                and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
                                and a.batch_number in(
                                    select
                                        max(batch_number)
                                    from
                                        tax_forms
                                    where
                                            a.tax_doc_type = tax_forms.tax_doc_type
                                        and a.acc_num = tax_forms.acc_num
                                        and begin_date = a.begin_date
                                        and end_date = a.end_date
                                )
                        )
                    returning clob)
                returning clob) files
            from
                dual
        ) loop
            l_1099_web := x.files;
        end loop;

        return l_1099_web;
    end; 

----------   07/04/2023 rprabu 
    function account_detail_report (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is
        l_acc_detail clob;
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'GET_dependent_'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'ADDRESS' value pc_web_utility_pkg.get_sterling_address1,
                                        key 'CITY' value pc_web_utility_pkg.get_sterling_city,
                                        key 'STATE' value pc_web_utility_pkg.get_sterling_state,
                                        key 'ZIP' value pc_web_utility_pkg.get_sterling_zip,
                                        key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ACC_NUM' value ac.acc_num,
                                        key 'ER_ADDRESS' value er.address,
                                        key 'ER_CITY' value er.city,
                                        key 'ER_STATE' value er.state,
                                        key 'ER_ZIP' value er.zip,
                                        key 'ER' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'E_ADD' value pc_entrp.get_entrp_name(p_entrp_id)
                                                          || ' , '
                                                          || pc_entrp.get_state(p_entrp_id)
                                                          || ',  '
                                                          || pc_entrp.get_city(p_entrp_id),
                                        key 'STMT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUMB' value replace(acc_num, '-'),
                                                        key 'NAME' value replace(first_name, '-')
                                                                         || ' '
                                                                         || last_name,
                                                        key 'FIRST_NAME' value first_name,
                                                        key 'LAST_NAME' value last_name,
                                                        key 'TERM_DATE' value to_char(end_date, 'MM/DD/YYYY'),
                                                        key 'PLAN_START_DATE' value to_char(start_date, 'MM/DD/YYYY'),
                                                        key 'ANNUAL_ELECTION' value annual_election,
                                                        key 'ACC_BALANCE' value pc_account.current_hrafsa_balance(acc_id, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY'),
                                                                                                                  to_date(p_plan_end_date
                                                                                                                  , 'MM/DD/YYYY'), to_date
                                                                                                                  (plan_end_date, 'MM/DD/YYYY'
                                                                                                                  ), plan_type),
                                                        key 'DEPOSIT' value pc_fin.contribution_ytd(acc_id, account_type, plan_type, to_date
                                                        (p_plan_start_date, 'MM/DD/YYYY'),
                                                                                                    to_date(p_plan_end_date, 'MM/DD/YYYY'
                                                                                                    )),
                                                        key 'DISBURSEMENT' value pc_fin.disbursement_ytd(acc_id, account_type, plan_type
                                                        , null, to_date(p_plan_start_date,
                        'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY')),
                                                        key 'CLAIM_FILED_YTD' value pc_fin.claim_filed_ytd(acc_id, account_type, plan_type
                                                        , to_date(p_plan_start_date, 'MM/DD/YYYY'),
                                                                                                           to_date(p_plan_end_date, 'MM/DD/YYYY'
                                                                                                           )),
                                                        key 'PRE_TAX' value(
                                                    select
                                                        pre_tax
                                                    from
                                                        table(pc_fin.get_balance_details(acc_id, plan_type, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                           'MM/DD/YYYY'), entrp_id))
                                                ),
                                                        key 'POST_TAX' value(
                                                    select
                                                        post_tax
                                                    from
                                                        table(pc_fin.get_balance_details(acc_id, plan_type, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                           'MM/DD/YYYY'), entrp_id))
                                                ),
                                                        key 'MONTHLY_CONTRIB' value(
                                                    select
                                                        monthly_contrib
                                                    from
                                                        table(pc_fin.get_balance_details(acc_id, plan_type, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                           'MM/DD/YYYY'), entrp_id))
                                                ),
                                                        key 'PLAN_TYPE_MEANING' value plan_type_meaning,
                                                        key 'PLAN_TYPE' value plan_type,
                                                        key 'DIV_NAME' value division_name,
                                                        key 'SSN' value lpad(
                                                    substr(
                                                        replace(ssn, '-'),
                                                        6,
                                                        9
                                                    ),
                                                    9,
                                                    '*'
                                                ),
                                                        key 'FB' value((pc_fin.contribution_ytd(acc_id, account_type, plan_type, to_date
                                                        (p_plan_start_date, 'MM/DD/YYYY'),
                                                                                                to_date(p_plan_end_date, 'MM/DD/YYYY'
                                                                                                ))) -(pc_fin.disbursement_ytd(acc_id,
                                                                                                account_type, plan_type, null, to_date
                                                                                                (p_plan_start_date,
                        'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY'))))
                                            )
                                        returning clob)
                                    from
                                        fsa_hra_employees_v
                                    where
                                            entrp_id = p_entrp_id
                                        and status not in('P', 'R')
                                        and plan_start_date = nvl(to_date(p_plan_start_date, 'MM/DD/YYYY'), plan_start_date)
                                        and plan_end_date = nvl(to_date(p_plan_end_date, 'MM/DD/YYYY'), plan_end_date)
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
                             -- AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_acc_detail := x.files;
        end loop;

        return l_acc_detail;
    end; 

----------   06/04/2023 rprabu list bill 
    function get_dependent (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return clob is
        l_dependent clob;
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'GET_dependent_'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'ADDRESS' value pc_web_utility_pkg.get_sterling_address1,
                                key 'CITY' value pc_web_utility_pkg.get_sterling_city,
                                key 'STATE' value pc_web_utility_pkg.get_sterling_state,
                                key 'ZIP' value pc_web_utility_pkg.get_sterling_zip,
                                key 'Plan_Start_Date' value p_plan_start_date,
                                key 'Plan_End_Date' value p_plan_end_date,
                                key 'Account_Number' value pc_entrp.get_acc_num(p_entrp_id),
                                key 'Employer_Address' value pc_entrp.get_entrp_name(p_entrp_id)
                                                             || ' , '
                                                             || pc_entrp.get_state(p_entrp_id)
                                                             || ',  '
                                                             || pc_entrp.get_city(p_entrp_id),
                                key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'SSN' value replace(a.ssn, '-'),
                                                key 'SUBSCRIBER_SSN' value replace(d.ssn, '-'),
                                                key 'FIRST_NAME' value a.first_name,
                                                key 'MIDDLE_NAME' value a.middle_name,
                                                key 'LAST_NAME' value a.last_name,
                                                key 'DAY_PHONE' value strip_bad(a.phone_day),
                                                key 'ADDRESS' value a.address,
                                                key 'CITY' value a.city,
                                                key 'STATE' value a.state,
                                                key 'ZIP' value a.zip,
                                                key 'BIRTH_DATE' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                                key 'RELATION' value pc_lookups.get_relat_code(a.relat_code)
                                    )
                                returning clob)
                            from
                                person  a,
                                person  d,
                                account b
                            where
                                    a.pers_main = d.pers_id
                                and d.entrp_id = p_entrp_id
                                and d.pers_id = b.pers_id
                                and exists(
                                    select
                                        *
                                    from
                                        ben_plan_enrollment_setup c
                                    where
                                            c.acc_id = b.acc_id
                                        and c.status in('P', 'A')
                                )
                                and a.pers_end_date is null
                        )
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
                             -- AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_dependent := x.files;
        end loop;

        return l_dependent;
    end; 

----------   06/04/2023 rprabu    list bill 
    function get_member (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return clob is
        l_get_member clob;
    begin
        if
            p_plan_start_date is null
            and p_plan_end_date is null
            and p_plan_type is null
        then
            for x in (
                select
                    json_arrayagg(
                        json_object(
                            key 'filename' value 'GET_PLANS_'
                                                 || p_entrp_id
                                                 || '.pdf',
                                    key 'ADDRESS' value pc_web_utility_pkg.get_sterling_address1,
                                    key 'CITY' value pc_web_utility_pkg.get_sterling_city,
                                    key 'STATE' value pc_web_utility_pkg.get_sterling_state,
                                    key 'ZIP' value pc_web_utility_pkg.get_sterling_zip,
                                    key 'Plan_Start_Date' value p_plan_start_date,
                                    key 'Plan_End_Date' value p_plan_end_date,
                                    key 'Account_Number' value pc_entrp.get_acc_num(p_entrp_id),
                                    key 'Employer_Address' value pc_entrp.get_entrp_name(p_entrp_id)
                                                                 || ' , '
                                                                 || pc_entrp.get_state(p_entrp_id)
                                                                 || ',  '
                                                                 || pc_entrp.get_city(p_entrp_id),
                                    key 'data' value(
                                select
                                    json_arrayagg(
                                        json_object(
                                            key 'SSN' value replace(a.ssn, '-'),
                                                    key 'GENDER' value a.gender,
                                                    key 'MIDDLE_NAME' value a.middle_name,
                                                    key 'LAST_NAME' value a.last_name,
                                                    key 'DAY_PHONE' value strip_bad(a.phone_day),    ---  TO_CHAR(:p_Plan_end_date,'MM/DD/YYYY') , 
                                                    key 'ADDRESS' value a.address,   ---TO_CHAR(:p_Plan_start_date,'MM/DD/YYYY') , 
                                                    key 'CITY' value a.city,
                                                    key 'STATE' value a.state,
                                                    key 'ZIP' value a.zip,
                                                    key 'EMAIL' value a.email,
                                                    key 'BIRTH_DATE' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                                    key 'EFFECTIVE_DATE' value to_char(c.effective_date, 'MM/DD/YYYY'),
                                                    key 'ANNUAL_ELECTION' value c.annual_election,
                                                    key 'DIVISION_NAME' value pc_person.get_division_name(a.pers_id),
                                                    key 'DEDUCTIBLE' value pc_benefit_plans.get_deductible(c.ben_plan_id_main, b.acc_id
                                                    ),
                                                    key 'COV_TIER_NAME' value pc_benefit_plans.get_cov_tier_name(c.ben_plan_id_main, b.acc_id
                                                    ),
                                                    key 'EFFECTIVE_END_DATE' value to_char(c.effective_end_date, 'MM/DD/YYYY'),
                                                    key 'DIVISION_NAME' value pc_person.get_division_name(a.pers_id),
                                                    key 'PLAN_START_DATE' value c.plan_start_date,
                                                    key 'PLAN_END_DATE' value c.plan_end_date,
                                                    key 'ACCOUNT_NUMBER' value b.acc_num,
                                                    key 'BEN_PLAN_ID' value c.ben_plan_id,
                                                    key 'ACCOUNT_ID' value c.acc_id,
                                                    key 'ACCOUNT_NUMBER' value b.acc_num,
                                                    key 'FUNDING_TYPE' value c.ben_plan_id,
                                                    key 'INVOICE_TYPE' value decode(d.claim_reimbursed_by, 'EMPLOYER', 'CLAIM_INVOICE'
                                                    , 'FUNDING_INVOICE')
                                        )
                                    returning clob)
                                from
                                    person                    a,
                                    account                   b,
                                    ben_plan_enrollment_setup c,
                                    ben_plan_enrollment_setup d
                                where
                                        a.entrp_id = p_entrp_id
                                    and c.ben_plan_id_main = d.ben_plan_id
                                    and a.pers_id = b.pers_id
                                    and b.acc_id = c.acc_id
                                    and c.plan_type = nvl(p_plan_type, c.plan_type)
                                    and c.status = 'A'
                                    and d.status = 'A'
                                    and c.plan_end_date >= nvl(p_plan_end_date, c.plan_end_date)
                                    and c.plan_start_date <= nvl(p_plan_start_date, c.plan_start_date)
                            )
                        returning clob)
                    returning clob) files
                from
                    enterprise er,
                    account    ac
                where
                        er.entrp_id = p_entrp_id
                    and er.entrp_id = ac.entrp_id
                    and ac.account_status = 1
                group by
                    er.entrp_id,
                    ac.acc_num
            ) loop
                l_get_member := x.files;
            end loop;
        end if;

        return l_get_member;
    end get_member; 

----------   29/03/2023 rprabu 
    function get_queen_enrolle_account_balance (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob is
        l_enrolle_account_bal clob;
        l_division_code       varchar2(10);
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Queen_Enrolle_'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'ENROLLE' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'ACC_ID' value acc_id,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'TERMINATION_DATE' value to_char(termination_date, 'MM/DD/YYYY'),    ---  TO_CHAR(:p_Plan_end_date,'MM/DD/YYYY') , 
                                                        key 'PLAN_START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),   ---TO_CHAR(:p_Plan_start_date,'MM/DD/YYYY') ,  
                                                        key 'ANNUAL_ELECTION' value annual_election,   
                                                                  /* Key 'ACC_BALANCE' Value to_number( PC_ACCOUNT.current_hrafsa_balance(
                                                                    ACC_ID,to_date(Plan_start_date,'MM/DD/YYYY'), to_date(Plan_end_date,'MM/DD/YYYY')
                                                                   ,PLAN_TYPE) ) ,    */
                                                        key 'DEPOSIT' value pc_fin.contribution_ytd(acc_id, account_type, plan_type, to_date
                                                        (p_plan_start_date, 'MM/DD/YYYY'),
                                                                                                    to_date(p_plan_end_date, 'MM/DD/YYYY'
                                                                                                    )),
                                                        key 'DISBURSEMENT' value pc_fin.disbursement_ytd(acc_id, account_type, plan_type
                                                        , null, to_date(p_plan_start_date,
                        'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY')),
                                                        key 'CLAIM_FILED_YTD' value pc_fin.claim_filed_ytd(acc_id, account_type, plan_type
                                                        , to_date(p_plan_start_date, 'MM/DD/YYYY'),
                                                                                                           to_date(p_plan_end_date, 'MM/DD/YYYY'
                                                                                                           )),
                                                        key 'Pre_tax' value(
                                                    select
                                                        pre_tax
                                                    from
                                                        table(pc_fin.get_balance_details(acc_id, plan_type, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                           'MM/DD/YYYY'), entrp_id))
                                                ),
                                                        key 'Post_tax' value(
                                                    select
                                                        post_tax
                                                    from
                                                        table(pc_fin.get_balance_details(acc_id, plan_type, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                           'MM/DD/YYYY'), entrp_id))
                                                ),
                                                        key 'Monthly_Contrib' value(
                                                    select
                                                        monthly_contrib
                                                    from
                                                        table(pc_fin.get_balance_details(acc_id, plan_type, to_date(p_plan_start_date
                                                        , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                           'MM/DD/YYYY'), entrp_id))
                                                ),
                                                        key 'PLAN_TYPE_MEANING' value plan_type_meaning,
                                                        key 'SSN' value lpad(
                                                    substr(
                                                        replace(ssn, '-'),
                                                        6,
                                                        9
                                                    ),
                                                    9,
                                                    '*'
                                                ),
                                                        key 'DIVISION_CODE' value division_code
                                            )
                                        returning clob)
                                    from
                                        fsa_hra_employees_queens_v
                                    where
                                            entrp_id = p_entrp_id  ----AND PLAN_TYPE = :p_plan_type
                                        and status not in('P', 'R')
                                        and plan_start_date = nvl(to_date(p_plan_start_date, 'MM/DD/YYYY'), plan_start_date)
                                        and plan_end_date = nvl(to_date(p_plan_end_date, 'MM/DD/YYYY'), plan_end_date)
                                ),
                                        key 'ENROLLE_SUM' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'SUM_ORI_ELE' value '$' || to_char(sum_original_elections, 'fm9999G990D00'),       ----1
                                                        key 'SUM_ROLL' value '$' || to_char(sum_rollover, 'fm9999G990D00'),               -----2  
                                                        key 'SUM_ANN_ELEC' value '$' || to_char(sum_annual_election, 'fm9999G990D00')
                                                        ,         ---- 3
                                                        key 'SUM_CONTRI_YTD' value '$' || to_char(sum_contr_ytd, 'fm9999G990D00'),               -----4
                                                        key 'SUM_CLAIMS_YTD' value '$' || to_char(sum_claims_ytd, 'fm9999G990D00'),              ---- 5
                                                        key 'SUM_FORF_BAL' value '$' || to_char(sum_forf_bal, 'fm9999G990D00'),                 --- 6
                                                        key 'SUM_ACC_BAL' value '$' || to_char(sum_acc_balance, 'fm9999G990D00')              ---- 7
                                            )
                                        returning clob)
                                    from
                                        (
                                            select
                                                entrp_id,         --- 1 
                                                sum(annual_election - pc_benefit_plans.get_rollover(acc_id, plan_type, to_date(p_plan_start_date
                                                , 'MM/DD/YYYY'), to_date(p_plan_end_date,
                                      'MM/DD/YYYY')))                                         sum_original_elections,     --- 6
                                                sum(pc_benefit_plans.get_rollover(acc_id, plan_type, to_date(p_plan_start_date, 'MM/DD/YYYY'
                                                ), to_date(p_plan_end_date,
                                      'MM/DD/YYYY')))                                         sum_rollover,   --- 7
                                                sum(pc_fin.contribution_ytd(acc_id, account_type, plan_type, to_date(p_plan_start_date
                                                , 'MM/DD/YYYY'),
                                                                            to_date(p_plan_end_date, 'MM/DD/YYYY')))                sum_contr_ytd
                                                                            ,     -----9 
                                                sum(pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, to_date(p_plan_start_date
                                                ,
                                'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY'))) sum_claims_ytd,            --- 10  
                                                sum(pc_fin.contribution_ytd(acc_id, account_type, plan_type, to_date(p_plan_start_date
                                                , 'MM/DD/YYYY'),
                                                                            to_date(p_plan_end_date, 'MM/DD/YYYY')) - pc_fin.disbursement_ytd
                                                                            (acc_id, account_type, plan_type, null, to_date(p_plan_start_date
                                                                            ,
                                'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY'))) sum_forf_bal,     --- 11 
                                                sum(pc_account.current_hrafsa_balance(acc_id, null, null, plan_start_date, plan_end_date
                                                ,
                                                                                      plan_type))                                             sum_acc_balance
                                                                                      ,
                                                sum(annual_election)                                    sum_annual_election
                                            from
                                                fsa_hra_employees_queens_v
                                            where
                                                    entrp_id = p_entrp_id
                                                and status not in('P', 'R')
                                                     ----AND Plan_Type =  nvl(p_plan_type, Plan_Type) 
                                                    ----   AND rownum < 1000
                                                and plan_start_date =(to_date(p_plan_start_date, 'MM/DD/YYYY'))
                                                and plan_end_date = to_date(p_plan_end_date, 'MM/DD/YYYY')
                                            group by
                                                entrp_id
                                        )
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_enrolle_account_bal := j.files;
        end loop;

        return l_enrolle_account_bal;
    end; 

----------   20/03/2023 rprabu  
    function get_contribution (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is

        l_contrib_clob  clob;
        l_division_code varchar2(10);
        l_ee_fsa_sum    number;
        l_er_fsa_sum    number;
        l_tot_fsa_sum   number;
        l_ee_dca_sum    number;
        l_er_dca_sum    number;
        l_tot_dca_sum   number;
        l_ee_trn_sum    number;
        l_er_trn_sum    number;
        l_tot_trn_sum   number;
        l_ee_lpf_sum    number;
        l_er_lpf_sum    number;
        l_tot_lpf_sum   number;

  --('LPF', 'HRA', 'PKG' , 'FSA', 'DCA' , 'HRP', 'TRN', 'UA1'  )      

        l_ee_pkg_sum    number;
        l_er_pkg_sum    number;
        l_tot_pkg_sum   number;
        l_ee_ua1_sum    number;
        l_er_ua1_sum    number;
        l_tot_ua1_sum   number;

                ------ FOr stacked accounts 
        l_ee_hra_sum    number;
        l_er_hra_sum    number;
        l_tot_hra_sum   number;
        l_ee_hrp_sum    number;
        l_er_hrp_sum    number;
        l_tot_hrp_sum   number;
        l_ee_sum        number;
        l_er_sum        number;
        l_tot_sum       number;
    begin
        for i in (
            select
                plan_type,
                sum(to_number(er_amount))                  sum_er_contrib,
                sum(to_number(ee_amount))                  sum_ee_contrib,
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) sum_total_contrib
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = p_entrp_id
            group by
                plan_type
        ) loop
            if i.plan_type = 'LPF' then
                l_ee_lpf_sum := i.sum_ee_contrib;
                l_er_lpf_sum := i.sum_ee_contrib;
                l_tot_lpf_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRA' then
                l_ee_hra_sum := i.sum_ee_contrib;
                l_er_hra_sum := i.sum_ee_contrib;
                l_tot_hra_sum := i.sum_total_contrib;
            elsif i.plan_type = 'PKG' then
                l_ee_pkg_sum := i.sum_ee_contrib;
                l_er_pkg_sum := i.sum_ee_contrib;
                l_tot_pkg_sum := i.sum_total_contrib;
            elsif i.plan_type = 'FSA' then
                l_ee_fsa_sum := i.sum_ee_contrib;
                l_er_fsa_sum := i.sum_ee_contrib;
                l_tot_fsa_sum := i.sum_total_contrib;
            elsif i.plan_type = 'DCA' then
                l_er_dca_sum := i.sum_ee_contrib;
                l_er_dca_sum := i.sum_ee_contrib;
                l_tot_dca_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRP' then
                l_ee_hrp_sum := i.sum_ee_contrib;
                l_er_hrp_sum := i.sum_ee_contrib;
                l_tot_hrp_sum := i.sum_total_contrib;
            elsif i.plan_type = 'TRN' then
                l_ee_trn_sum := i.sum_ee_contrib;
                l_er_trn_sum := i.sum_ee_contrib;
                l_tot_trn_sum := i.sum_total_contrib;
            elsif i.plan_type = 'UA1' then
                l_ee_ua1_sum := i.sum_ee_contrib;
                l_er_ua1_sum := i.sum_ee_contrib;
                l_tot_ua1_sum := i.sum_total_contrib;
            end if;
        end loop; 

         ------------- GRAND TOTAL 
        for i in (
            select
                sum(to_number(er_amount))                  sum_er_contrib,
                sum(to_number(ee_amount))                  sum_ee_contrib,
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) sum_total_contrib
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = to_number(p_entrp_id)
        ) loop
            l_ee_sum := i.sum_ee_contrib;
            l_er_sum := i.sum_ee_contrib;
            l_tot_sum := i.sum_total_contrib;
        end loop; 

   --('LPF', 'HRA', 'PKG' , 'FSA', 'DCA' , 'HRP', 'TRN', 'UA1'  )   

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Contribution_'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'EE_SUM' value l_ee_sum,
                                        key 'ER_SUM' value l_er_sum,
                                        key 'TOT_SUM' value l_tot_sum,
                                        key 'EE_LPF_SUM' value l_ee_lpf_sum,
                                        key 'ER_LPF_SUM' value l_er_lpf_sum,
                                        key 'TOT_LPF_SUM' value l_tot_lpf_sum,
                                        key 'EE_HRP_SUM' value l_ee_hrp_sum,
                                        key 'ER_HRP_SUM' value l_er_hrp_sum,
                                        key 'TOT_HRP_SUM' value l_tot_hrp_sum,
                                        key 'EE_HRA_SUM' value l_ee_hra_sum,
                                        key 'ER_HRA_SUM' value l_er_hra_sum,
                                        key 'TOT_HRA_SUM' value l_tot_hra_sum,
                                        key 'EE_PKG_SUM' value l_ee_pkg_sum,
                                        key 'ER_PKG_SUM' value l_er_pkg_sum,
                                        key 'L_TOT_PKG_SUM' value l_tot_pkg_sum,
                                        key 'EE_FSA_SUM' value l_ee_fsa_sum,
                                        key 'ER_FSA_SUM' value l_er_fsa_sum,
                                        key 'TOT_FSA_SUM' value l_tot_fsa_sum,
                                        key 'EE_DCA_SUM' value l_er_dca_sum,
                                        key 'ER_DCA_SUM' value l_er_dca_sum,
                                        key 'TOT_DCA_SUM' value l_tot_dca_sum,
                                        key 'EE_HRP_SUM' value l_ee_hrp_sum,
                                        key 'ER_HRP_SUM' value l_er_hrp_sum,
                                        key 'TOT_HRP_SUM' value l_tot_hrp_sum,
                                        key 'EE_SUM' value l_ee_trn_sum,
                                        key 'ER_TRN_SUM' value l_er_trn_sum,
                                        key 'TOT_TRN_SUM' value l_tot_trn_sum,
                                        key 'EE_UA1_SUM' value l_ee_ua1_sum,
                                        key 'ER_UA1_SUM' value l_er_ua1_sum,
                                        key 'TOT_UA1_SUM' value l_tot_ua1_sum,
                                        key 'ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'CON_HRA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(ee_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'HRA'
                                        and entrp_id = p_entrp_id
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_HRP' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char((sum(er_amount)),
                                                                                          'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char((sum(ee_amount)),
                                                                                          'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'HRP'
                                        and entrp_id = p_entrp_id
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_FSA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(ee_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and entrp_id = p_entrp_id
                                        and plan_type = 'FSA'
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_DCA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char((sum(er_amount)),
                                                                                          'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and entrp_id = p_entrp_id
                                        and plan_type = 'DCA'
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_LPF' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(ee_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'LPF'
                                        and entrp_id = p_entrp_id
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_UA1' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(ee_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'UA1'
                                        and entrp_id = p_entrp_id
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_TRN' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'TRN'
                                        and entrp_id = p_entrp_id
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                ),
                                        key 'CON_PKG' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(er_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char(
                                                    sum(ee_amount),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(sum(er_amount) + sum(ee_amount),
                                                                                            'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'LPF'
                                        and plan_type = 'PKG'
                                        and entrp_id = p_entrp_id
                                    group by
                                        acc_num,
                                        first_name
                                        || ' '
                                        || last_name,
                                        division_name
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_contrib_clob := j.files;
        end loop;

        return l_contrib_clob;
    end get_contribution;

    function get_contribution_details (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is

        l_contrib_details_clob clob;
        l_division_code        varchar2(10);
        l_ee_fsa_sum           number;
        l_er_fsa_sum           number;
        l_tot_fsa_sum          number;
        l_ee_dca_sum           number;
        l_er_dca_sum           number;
        l_tot_dca_sum          number;
        l_ee_trn_sum           number;
        l_er_trn_sum           number;
        l_tot_trn_sum          number;
        l_ee_lpf_sum           number;
        l_er_lpf_sum           number;
        l_tot_lpf_sum          number;

  --('LPF', 'HRA', 'PKG' , 'FSA', 'DCA' , 'HRP', 'TRN', 'UA1'  )      

        l_ee_pkg_sum           number;
        l_er_pkg_sum           number;
        l_tot_pkg_sum          number;
        l_ee_ua1_sum           number;
        l_er_ua1_sum           number;
        l_tot_ua1_sum          number;

                ------ FOr stacked accounts 
        l_ee_hra_sum           number;
        l_er_hra_sum           number;
        l_tot_hra_sum          number;
        l_ee_hrp_sum           number;
        l_er_hrp_sum           number;
        l_tot_hrp_sum          number;
        l_ee_sum               number;
        l_er_sum               number;
        l_tot_sum              number;
    begin
        for i in (
            select
                plan_type,
                sum(to_number(er_amount))                  sum_er_contrib,
                sum(to_number(ee_amount))                  sum_ee_contrib,
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) sum_total_contrib
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = p_entrp_id
            group by
                plan_type
        ) loop
            if i.plan_type = 'LPF' then
                l_ee_lpf_sum := i.sum_ee_contrib;
                l_er_lpf_sum := i.sum_ee_contrib;
                l_tot_lpf_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRA' then
                l_ee_hra_sum := i.sum_ee_contrib;
                l_er_hra_sum := i.sum_ee_contrib;
                l_tot_hra_sum := i.sum_total_contrib;
            elsif i.plan_type = 'PKG' then
                l_ee_pkg_sum := i.sum_ee_contrib;
                l_er_pkg_sum := i.sum_ee_contrib;
                l_tot_pkg_sum := i.sum_total_contrib;
            elsif i.plan_type = 'FSA' then
                l_ee_fsa_sum := i.sum_ee_contrib;
                l_er_fsa_sum := i.sum_ee_contrib;
                l_tot_fsa_sum := i.sum_total_contrib;
            elsif i.plan_type = 'DCA' then
                l_er_dca_sum := i.sum_ee_contrib;
                l_er_dca_sum := i.sum_ee_contrib;
                l_tot_dca_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRP' then
                l_ee_hrp_sum := i.sum_ee_contrib;
                l_er_hrp_sum := i.sum_ee_contrib;
                l_tot_hrp_sum := i.sum_total_contrib;
            elsif i.plan_type = 'TRN' then
                l_ee_trn_sum := i.sum_ee_contrib;
                l_er_trn_sum := i.sum_ee_contrib;
                l_tot_trn_sum := i.sum_total_contrib;
            elsif i.plan_type = 'UA1' then
                l_ee_ua1_sum := i.sum_ee_contrib;
                l_er_ua1_sum := i.sum_ee_contrib;
                l_tot_ua1_sum := i.sum_total_contrib;
            end if;
        end loop; 

         ------------- GRAND TOTAL 
        for i in (
            select
                sum(to_number(er_amount))                  sum_er_contrib,
                sum(to_number(ee_amount))                  sum_ee_contrib,
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) sum_total_contrib
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = to_number(p_entrp_id)
        ) loop
            l_ee_sum := i.sum_ee_contrib;
            l_er_sum := i.sum_ee_contrib;
            l_tot_sum := i.sum_total_contrib;
        end loop;

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Contribution_'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                          /*  KEY 'EE_SUM' VALUE L_EE_SUM,
                            KEY 'ER_SUM' VALUE L_ER_SUM,
                            KEY 'TOT_SUM' VALUE L_TOT_SUM, 
                            KEY 'EE_LPF_SUM' VALUE L_EE_LPF_SUM,
                            KEY 'ER_LPF_SUM' VALUE L_ER_LPF_SUM,
                            KEY 'TOT_LPF_SUM' VALUE L_TOT_LPF_SUM, 
                            KEY 'EE_HRP_SUM' VALUE L_EE_HRP_SUM,
                            KEY 'ER_HRP_SUM' VALUE L_ER_HRP_SUM,
                            KEY 'TOT_HRP_SUM' VALUE L_TOT_HRP_SUM, 
                            KEY 'EE_HRA_SUM' VALUE L_EE_HRA_SUM,
                            KEY 'ER_HRA_SUM' VALUE L_ER_HRA_SUM,
                            KEY 'TOT_HRA_SUM' VALUE L_TOT_HRA_SUM, 
                            KEY 'EE_PKG_SUM' VALUE L_EE_PKG_SUM,
                            KEY 'ER_PKG_SUM' VALUE L_ER_PKG_SUM,
                            KEY 'L_TOT_PKG_SUM' VALUE L_TOT_PKG_SUM, 
                            KEY 'EE_FSA_SUM' VALUE L_EE_FSA_SUM,
                            KEY 'ER_FSA_SUM' VALUE L_ER_FSA_SUM,
                            KEY 'TOT_FSA_SUM' VALUE L_TOT_FSA_SUM, 
                            KEY 'EE_DCA_SUM' VALUE L_ER_DCA_SUM,
                            KEY 'ER_DCA_SUM' VALUE L_ER_DCA_SUM,
                            KEY 'TOT_DCA_SUM' VALUE L_TOT_DCA_SUM, 
                            KEY 'EE_HRP_SUM' VALUE L_EE_HRP_SUM,
                            KEY 'ER_HRP_SUM' VALUE L_ER_HRP_SUM,
                            KEY 'TOT_HRP_SUM' VALUE L_TOT_HRP_SUM, 
                            KEY 'EE_SUM' VALUE L_EE_TRN_SUM,
                            KEY 'ER_TRN_SUM' VALUE L_ER_TRN_SUM,
                            KEY 'TOT_TRN_SUM' VALUE L_TOT_TRN_SUM, 
                            KEY 'EE_UA1_SUM' VALUE L_EE_UA1_SUM,
                            KEY 'ER_UA1_SUM' VALUE L_ER_UA1_SUM,
                            KEY 'TOT__UA1_SUM' VALUE L_TOT_UA1_SUM,*/
                                        key 'ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'CON_HRA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(l_er_hra_sum, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(l_ee_hra_sum, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$' || to_char(l_tot_hra_sum, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'HRA'
                                        and entrp_id = p_entrp_id
                                ), 
                                                ---   GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) , 
                                        key 'CON_HRP' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char((l_er_hrp_sum), 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char((l_ee_hrp_sum), 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$' || to_char(l_tot_hrp_sum, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'HRP'
                                        and entrp_id = p_entrp_id
                                ), 
                                            --       GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) , 
                                        key 'CON_FSA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(er_amount, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and entrp_id = p_entrp_id
                                        and plan_type = 'FSA'
                                ),
                                        key 'CON_DCA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char((er_amount), 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and entrp_id = p_entrp_id
                                        and plan_type = 'DCA'
                                ), 
                                               ---   GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) ,
                                        key 'CON_LPF' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(er_amount, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'LPF'
                                        and entrp_id = p_entrp_id
                                ), 
                                            ---   GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ),
                                        key 'CON_UA1' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(er_amount, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'UA1'
                                        and entrp_id = p_entrp_id
                                ), 
                                               ---    GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) ,
                                        key 'CON_TRN' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(er_amount, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'FSA'
                                        and plan_type = 'TRN'
                                        and entrp_id = p_entrp_id
                                ),
                                     ----              GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) ,
                                        key 'CON_PKG' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(er_amount, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and account_type = 'LPF'
                                        and plan_type = 'PKG'
                                        and entrp_id = p_entrp_id
                                ) 
                                               ---    GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) 
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_contrib_details_clob := j.files;
        end loop;

        return l_contrib_details_clob;
 --('LPF', 'HRA', 'PKG' , 'FSA', 'DCA' , 'HRP', 'TRN', 'UA1'  )   
    end get_contribution_details;

    function get_contribution_details_hra (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is

        l_contrib_details_clob clob;
        l_division_code        varchar2(10);
        l_ee_hr4_sum           number;
        l_er_hr4_sum           number;
        l_tot_hr4_sum          number;
        l_ee_hr5_sum           number;
        l_er_hr5_sum           number;
        l_tot_hr5_sum          number;
        l_ee_hra_sum           number;
        l_er_hra_sum           number;
        l_tot_hra_sum          number;
        l_ee_hrp_sum           number;
        l_er_hrp_sum           number;
        l_tot_hrp_sum          number;
        l_ee_sum               number;
        l_er_sum               number;
        l_tot_sum              number;
    begin
        for i in (
            select
                plan_type,
                sum(to_number(er_amount))                  sum_er_contrib,
                sum(to_number(ee_amount))                  sum_ee_contrib,
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) sum_total_contrib
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = p_entrp_id
            group by
                plan_type
        ) loop      --('HR4', 'HR5', 'HRA' , 'HRP')   
            if i.plan_type = 'HR4' then
                l_ee_hr4_sum := i.sum_ee_contrib;
                l_er_hr4_sum := i.sum_ee_contrib;
                l_tot_hr4_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRA' then
                l_ee_hra_sum := i.sum_ee_contrib;
                l_er_hra_sum := i.sum_ee_contrib;
                l_tot_hra_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HR5' then
                l_ee_hr5_sum := i.sum_ee_contrib;
                l_er_hr5_sum := i.sum_ee_contrib;
                l_tot_hr5_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRA' then
                l_ee_hra_sum := i.sum_ee_contrib;
                l_er_hra_sum := i.sum_ee_contrib;
                l_tot_hra_sum := i.sum_total_contrib;
            elsif i.plan_type = 'HRP' then
                l_er_hrp_sum := i.sum_ee_contrib;
                l_er_hrp_sum := i.sum_ee_contrib;
                l_tot_hrp_sum := i.sum_total_contrib;
            end if; 
                    /*   ELSIF   I.Plan_Type  =  'TRN'  Then
                            L_EE_TRN_SUM := I.SUM_EE_CONTRIB ;
                            L_ER_TRN_SUM := I.SUM_EE_CONTRIB ;
                            L_TOT_TRN_SUM := I.SUM_TOTAL_CONTRIB ; 
                       ELSIF  I.Plan_Type  =  'UA1'  Then
                            L_EE_UA1_SUM := I.SUM_EE_CONTRIB ;
                            L_ER_UA1_SUM := I.SUM_EE_CONTRIB ;
                            L_TOT_UA1_SUM := I.SUM_TOTAL_CONTRIB ;  */

        end loop; 

         ------------- GRAND TOTAL 
        for i in (
            select
                sum(to_number(er_amount))                  sum_er_contrib,
                sum(to_number(ee_amount))                  sum_ee_contrib,
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) sum_total_contrib
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = to_number(p_entrp_id)
        ) loop
            l_ee_sum := i.sum_ee_contrib;
            l_er_sum := i.sum_ee_contrib;
            l_tot_sum := i.sum_total_contrib;
        end loop;

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Contribution_'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                         /*   KEY 'EE_SUM' VALUE L_EE_SUM,
                            KEY 'ER_SUM' VALUE L_ER_SUM,
                            KEY 'TOT_SUM' VALUE L_TOT_SUM, 
                            KEY 'EE_LPF_SUM' VALUE L_EE_LPF_SUM,
                            KEY 'ER_LPF_SUM' VALUE L_ER_LPF_SUM,
                            KEY 'TOT_LPF_SUM' VALUE L_TOT_LPF_SUM, 
                            KEY 'EE_HRP_SUM' VALUE L_EE_HRP_SUM,
                            KEY 'ER_HRP_SUM' VALUE L_ER_HRP_SUM,
                            KEY 'TOT_HRP_SUM' VALUE L_TOT_HRP_SUM, 
                            KEY 'EE_HRA_SUM' VALUE L_EE_HRA_SUM,
                            KEY 'ER_HRA_SUM' VALUE L_ER_HRA_SUM,
                            KEY 'TOT_HRA_SUM' VALUE L_TOT_HRA_SUM, 
                            KEY 'EE_PKG_SUM' VALUE L_EE_PKG_SUM,
                            KEY 'ER_PKG_SUM' VALUE L_ER_PKG_SUM,
                            KEY 'L_TOT_PKG_SUM' VALUE L_TOT_PKG_SUM, 
                            KEY 'EE_FSA_SUM' VALUE L_EE_FSA_SUM,
                            KEY 'ER_FSA_SUM' VALUE L_ER_FSA_SUM,
                            KEY 'TOT_FSA_SUM' VALUE L_TOT_FSA_SUM, 
                            KEY 'EE_DCA_SUM' VALUE L_ER_DCA_SUM,
                            KEY 'ER_DCA_SUM' VALUE L_ER_DCA_SUM,
                            KEY 'TOT_DCA_SUM' VALUE L_TOT_DCA_SUM, 
                            KEY 'EE_HRP_SUM' VALUE L_EE_HRP_SUM,
                            KEY 'ER_HRP_SUM' VALUE L_ER_HRP_SUM,
                            KEY 'TOT_HRP_SUM' VALUE L_TOT_HRP_SUM, 
                            KEY 'EE_SUM' VALUE L_EE_TRN_SUM,
                            KEY 'ER_TRN_SUM' VALUE L_ER_TRN_SUM,
                            KEY 'TOT_TRN_SUM' VALUE L_TOT_TRN_SUM, 
                            KEY 'EE_UA1_SUM' VALUE L_EE_UA1_SUM,
                            KEY 'ER_UA1_SUM' VALUE L_ER_UA1_SUM,
                            KEY 'TOT__UA1_SUM' VALUE L_TOT_UA1_SUM, */
                                        key 'ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'CON_HRA' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(l_er_hra_sum, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(l_ee_hra_sum, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$' || to_char(l_tot_hra_sum, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                               ---    AND account_type ='FSA'
                                        and plan_type = 'HRA'
                                        and entrp_id = p_entrp_id
                                ), 
                                                ---   GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) , 
                                        key 'CON_HRP' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char((l_er_hrp_sum), 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$'
                                                                               || to_char((l_ee_hrp_sum), 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$' || to_char(l_tot_hrp_sum, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                                  --- AND account_type ='FSA'
                                        and plan_type = 'HRP'
                                        and entrp_id = p_entrp_id
                                ), 
                                            --       GROUP BY ACC_NUM, First_name || ' ' ||LAST_NAME ,DIVISION_NAME ) , 
                                        key 'CON_HR5' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$' || to_char(er_amount, 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and entrp_id = p_entrp_id
                                        and plan_type = 'HR5'
                                ),
                                        key 'CON_HR4' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'ER_CONTRIB' value '$'
                                                                               || to_char((er_amount), 'fm9999G990D00'),
                                                        key 'EE_CONTRIB' value '$' || to_char(ee_amount, 'fm9999G990D00'),
                                                        key 'TOTAL_AMOUNT' value '$'
                                                                                 || to_char(ee_amount + er_amount, 'fm9999G990D00')
                                            )
                                        returning clob)
                                    from
                                        ee_deposits_v
                                    where
                                            fee_date >= p_plan_start_date
                                        and fee_date <= p_plan_end_date
                                        and entrp_id = p_entrp_id
                                        and plan_type = 'HR4'
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
             --- AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_contrib_details_clob := j.files;
        end loop;

        return l_contrib_details_clob;
 --('LPF', 'HRA', 'PKG' , 'FSA', 'DCA' , 'HRP', 'TRN', 'UA1'  )   
    end get_contribution_details_hra;

-- 06/28 hari . We do not required below function check once APEX is back on-line before deleting the code
    function get_manual_claims (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is
        l_claim_clob clob;
        v_deb_pay    number;
        v_pro_pay    number;
        v_par_reim   number;
        v_tot_pay    number;
    begin
        pc_log.log_error('get_manual_Claims', ' p_entrp_id '
                                              || p_entrp_id
                                              || ' p_plan_start_date '
                                              || p_plan_start_date
                                              || ' p_plan_end_date '
                                              || p_plan_end_date);

        select
            nvl(
                sum(
                    case
                        when reimbursement_method = 'Debit Card Purchase' then
                            check_amount
                    end
                ),
                0
            ),
            nvl(
                sum(
                    case
                        when reimbursement_method = 'To Provider' then
                            check_amount
                    end
                ),
                0
            ),
            nvl(
                sum(
                    case
                        when reimbursement_method not in('Debit Card Purchase', 'To Provider') then
                            check_amount
                    end
                ),
                0
            )
        into
            v_deb_pay,
            v_pro_pay,
            v_par_reim
        from
            claim_report_online_v
        where
                entrp_id = p_entrp_id
            and trunc(plan_start_date) >= p_plan_start_date
            and trunc(plan_end_date) <= p_plan_end_date;

        v_tot_pay := v_deb_pay + v_pro_pay + v_par_reim;
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'dEBIT_CARD_report'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'EMP_ADDR1' value er.address,
                                        key 'EMP_ADDR2' value er.city
                                                              || ', '
                                                              || er.state
                                                              || ' '
                                                              || er.zip,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'PART_REIM' value '$' || to_char(v_par_reim, 'fm9999G990D00'),
                                        key 'PRO_PAY' value '$' || to_char(v_pro_pay, 'fm9999G990D00'),
                                        key 'DEB_PAY' value '$' || to_char(v_deb_pay, 'fm9999G990D00'),
                                        key 'TOTAL_SAL' value '$' || to_char(v_tot_pay, 'fm9999G990D00'),
                                        key 'PLAN_DET' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PLAN_TYPE' value plan_type,
                                                key 'PLAN_DESC' value plan_type_meaning
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select distinct
                                                plan_type,
                                                plan_type_meaning
                                            from
                                                fsa_hra_er_ben_plans_v plans_v
                                            where
                                                plans_v.entrp_id = p_entrp_id
                                        )
                                ),
                                        key 'CLAIMS' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value acc_num,
                                                        key 'FIRST_NAME' value first_name,
                                                        key 'LAST_NAME' value last_name,
                                                        key 'DIV_NAME' value division_name,
                                                        key 'PAID_DATE' value to_char(pay_date, 'mm/dd/yyyy'),
                                                        key 'CLAIM_NO' value transaction_number,
                                                        key 'CLAIM_AMT' value nvl(claim_amount, 0), -- '$'||TO_CHAR(nvl(CLAIM_AMOUNT,0),'fm9999G990D00'),
                                                        key 'APPR_AMT' value nvl(approved_amount, 0), -- '$'||TO_CHAR(nvl(APPROVED_AMOUNT,0),'fm9999G990D00'),
                                                        key 'PENDED_AMT' value nvl(claim_pending, 0), --   '$'||TO_CHAR(nvl(CLAIM_PENDING,0) ,'fm9999G990D00'),
                                                        key 'PAID_AMT' value nvl(check_amount, 0), -- '$'||TO_CHAR(nvl(CHECK_AMOUNT,0),'fm9999G990D00'),
                                                        key 'PLAN_YEAR' value to_char(plan_start_date, 'MM/DD/YYYY')
                                                                              || '-'
                                                                              || to_char(plan_end_date, 'MM/DD/YYYY'),
                                                        key 'REIM_METHOD' value reimbursement_method,
                                                        key 'DEN_AMT' value '$'
                                                                            || to_char(
                                                    nvl(denied_amount, 0),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'EMP_NAME' value first_name
                                                                             || ' '
                                                                             || last_name,
                                                        key 'CHECK_NUMBER' value check_number,
                                                        key 'DIVISION_CODE' value division_code,
                                                        key 'REASON_CODE' value reason_code,
                                                        key 'SERVICE_TYPE' value service_type,
                                                        key 'SERVICE_TYPE_MEANING' value service_type_meaning,
                                                        key 'PLAN_START_DATE' value plan_start_date,
                                                        key 'PLAN_END_DATE' value plan_end_date,
                                                        key 'ACC_BALANCE' value '$'
                                                                                || to_char(
                                                    nvl(
                                                        pc_account.acc_balance(acc_id, plan_start_date, plan_end_date, 'FSA', service_type
                                                        ,
                                                                               plan_start_date, plan_end_date),
                                                        0
                                                    ),
                                                    'fm9999G990D00'
                                                )
                                            )
                                        returning clob)
                                    from
                                        claim_report_online_v
                                    where
                                            entrp_id = p_entrp_id
                                        and trunc(plan_start_date) >= p_plan_start_date
                                        and trunc(plan_end_date) <= p_plan_end_date
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
          ---    AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_claim_clob := j.files;
        end loop;

        return l_claim_clob;
    end get_manual_claims; 
-- VANITHA TO HARI : IF NOT USED REMOVE IT 
-- 06/28 not required hari commenting will remove after testing 
/*
FUNCTION get_Claims (    p_entrp_id        IN NUMBER
                                    ,p_start_date      IN DATE
                                    ,p_end_date        IN DATE
                                    ,p_plan_start_date IN DATE
                                    ,p_plan_end_date   IN DATE
                                    ,p_plan_type       IN VARCHAR2
                                    ,p_division_code   IN VARCHAR2
			     )
             RETURN cLOB     IS 
       l_Claim_clob CLOB; 
      Begin 
       FOR J IN    (SELECT json_arrayagg(
                         json_object(
                           KEY 'filename' value 'get_Claims'||p_entrp_id||'.pdf',
                           KEY 'data' VALUE json_arrayagg ( JSON_OBJECT( 
                                 Key  'Acc_Num'  Value   Acc_Num  ,
                                    Key  'First_Name'  Value     First_Name,
                                    Key  'Last_Name'  Value       Last_Name ,
                                    Key  'PAY_DATE'  Value   to_char(PAY_DATE,'mm/dd/yyyy')  ,
                                    Key  'APPROVED_AMOUNT'  Value     APPROVED_AMOUNT,
                                    Key  'CLAIM_PENDING'  Value       CLAIM_PENDING ,
                                    Key  'CHECK_AMOUNT'  Value     CHECK_AMOUNT,
                                    Key  'CHECK_NUMBER'  Value       CHECK_NUMBER ,
                                    Key  'CLAIM_AMOUNT'  Value     CLAIM_AMOUNT,
                                    Key  'TRANSACTION_NUMBER'  Value       TRANSACTION_NUMBER ,
                                    Key  'REIMBURSEMENT_METHOD'  Value     REIMBURSEMENT_METHOD,
                                    Key  'DIVISION_CODE'  Value       DIVISION_CODE ,
                                    Key  'DIVISION_NAME'  Value     DIVISION_NAME,
                                    Key  'REASON_CODE'  Value       REASON_CODE ,
                                    Key  'SERVICE_TYPE'  Value     SERVICE_TYPE,
                                    Key  'SERVICE_TYPE_MEANING'  Value       SERVICE_TYPE_MEANING ,
                                    Key  'DENIED_AMOUNT'  Value     DENIED_AMOUNT,
                                    Key  'PLAN_START_DATE'  Value       PLAN_START_DATE ,
                                    Key  'PLAN_END_DATE'  Value     PLAN_END_DATE)
                                returning clob)returning clob)returning clob)    files 
                          from CLAIM_REPORT_ONLINE_V
                         where ENTRP_ID = p_entrp_id
                         and   TRUNC(PLAN_START_DATE) >= p_plan_start_date
                         and   TRUNC(PLAN_END_DATE) <= p_plan_end_date
                         and   SERVICE_TYPE   = NVL(p_plan_type,SERVICE_TYPE)
                         and  ( DIVISION_CODE IS NULL
                               OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END)
                            UNION ALL    
                              SELECT json_arrayagg(
                         json_object(
                           KEY 'filename' value 'get_Claims'||p_entrp_id||'.pdf',
                           KEY 'data' VALUE json_arrayagg ( JSON_OBJECT( 
                                   Key  'Acc_Num'  Value  C.ACC_NUM,
                                    Key  'First_Name'  Value     FIRST_NAME,
                                    Key  'Last_Name'  Value       LAST_NAME ,
                                    Key  'PAY_DATE'  Value  NULL ,
                                    Key  'APPROVED_AMOUNT'  Value      B.APPROVED_AMOUNT,
                                    Key  'CLAIM_PENDING'  Value        B.CLAIM_PENDING ,
                                    Key  'CHECK_AMOUNT'  Value     NULL,
                                    Key  'CHECK_NUMBER'  Value       NULL ,
                                    Key  'CLAIM_AMOUNT'  Value     TO_NUMBER(B.CLAIM_AMOUNT) ,
                                    Key  'TRANSACTION_NUMBER'  Value       B.CLAIM_ID  ,
                                    Key  'REIMBURSEMENT_METHOD'  Value     NULL,
                                    Key  'DIVISION_CODE'  Value        PC_PERSON.GET_DIVISION_CODE(B.PERS_ID) ,
                                    Key  'DIVISION_NAME'  Value     PC_PERSON.GET_DIVISION_NAME(B.PERS_ID) ,
                                    Key  'REASON_CODE'  Value       0 ,
                                    Key  'SERVICE_TYPE'  Value      B.SERVICE_TYPE,
                                    Key  'SERVICE_TYPE_MEANING'  Value         pc_lookups.GET_FSA_PLAN_TYPE(b.service_type) ,
                                    Key  'DENIED_AMOUNT'  Value      B.DENIED_AMOUNT,
                                    Key  'PLAN_START_DATE'  Value        B.PLAN_START_DATE ,
                                    Key  'PLAN_END_DATE'  Value      B.PLAN_END_DATE)
                                returning clob)returning clob)returning clob)    files 
                          FROM PAYMENT_REGISTER A ,
                          CLAIMN B ,
                          ACCOUNT C ,
                          PERSON E
                          WHERE A.ENTRP_ID   = B.ENTRP_ID
                          AND E.ENTRP_ID     = B.ENTRP_ID  
                          AND A.CLAIM_ID     = B.CLAIM_ID
                          AND E.PERS_ID      = B.PERS_ID
                          AND C.PERS_ID      = B.PERS_ID  ---New
                          AND B.CLAIM_STATUS = 'DENIED'
                          AND B.entrp_id = p_entrp_id
                          AND B.CLAIM_STATUS NOT IN ('ERROR','CANCELLED')
                          and   TRUNC(CLAIM_DATE) >= p_plan_start_date
                          and   TRUNC(CLAIM_DATE) <= p_plan_end_date
                          and   ( DIVISION_CODE IS NULL
                                  OR DIVISION_CODE  = CASE WHEN p_division_code = 'ALL_DIVISION' THEN DIVISION_CODE ELSE p_division_code END)
                               )

                  LOOP
                         l_Claim_clob := j.files;
                  END LOOP;

          RETURN l_Claim_clob ; 

      ENd get_Claims; 
*/

    function get_enrolle_balance (
        p_entrp_id        in number,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob is
        l_clob clob;
    begin
        if p_entrp_id in ( 29742, 9105 ) then
            for j in (
                select
                    json_arrayagg(
                        json_object(
                            key 'file_name' value 'ENROLLE_BALANCE'
                                                  || p_entrp_id
                                                  || '.pdf',
                                    key 'data' value json_arrayagg(
                                    json_object(
                                    key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                            key 'entrp_name' value er.name,
                                            key 'ENROLLE' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'Acc_Num' value acc_num,
                                                            key 'First_Name' value first_name,
                                                            key 'Termination_Date' value to_char(end_date, 'MM/DD/YYYY'),
                                                            key 'Plan_Start_Date' value to_char(start_date, 'MM/DD/YYYY'),
                                                            key 'Start_Date' value start_date,
                                                            key 'Annual_Election' value annual_election,
                                                            key 'Acc_Id' value acc_id,
                                                            key 'Account_Type' value account_type,
                                                            key 'End_Date' value end_date,
                                                            key 'Plan_Type_Meaning' value plan_type_meaning,
                                                            key 'Plan_Type' value plan_type,
                                                            key 'Division_Code' value division_code,
                                                            key 'Division_Name' value division_name,
                                                            key 'runout_period_days' value runout_period_days,
                                                            key 'grace_period' value grace_period,
                                                            key 'entrp_id' value entrp_id
                                                returning clob)
                                            returning clob) enrolle_balance
                                        from
                                            fsa_hra_employees_queens_v
                                        where
                                                plan_start_date = to_date(p_plan_start_date, 'MM/DD/YYYY')
                                            and plan_end_date = to_date(p_plan_end_date, 'MM/DD/YYYY')
                                            and entrp_id = p_entrp_id
                                    )
                                returning clob)
                            returning clob)
                        returning clob)
                    returning clob) files
                from
                    enterprise er,
                    account    ac
                where
                        er.entrp_id = p_entrp_id
                    and er.entrp_id = ac.entrp_id
											  --AND   AC.ACCOUNT_STATUS = 1
                group by
                    er.entrp_id,
                    ac.acc_num
            ) loop
                l_clob := j.files;
            end loop;
        else
            for j in (
                select
                    json_arrayagg(
                        json_object(
                            key 'file_name' value 'ENROLLE_BALANCE'
                                                  || p_entrp_id
                                                  || '.pdf',
                                    key 'data' value json_arrayagg(
                                    json_object(
                                    key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                            key 'entrp_name' value er.name,
                                            key 'ENROLLE' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'ACC_NUM' value acc_num,
                                                            key 'FIRST_NAME' value first_name,
                                                            key 'LAST_NAME' value last_name,
                                                            key 'TERMINATION_DATE' value to_char(end_date, 'MM/DD/YYYY'),
                                                            key 'PLAN_START_DATE' value to_char(start_date, 'MM/DD/YYYY'),
                                                            key 'Annual_Election' value annual_election,
                                                            key 'Acc_Id' value acc_id,
                                                            key 'Account_Type' value to_char(end_date, 'MM/DD/YYYY'),
                                                            key 'End_Date' value to_char(end_date, 'MM/DD/YYYY'),
                                                            key 'Plan_Type_Meaning' value plan_type_meaning,
                                                            key 'Plan_Type' value plan_type,
                                                            key 'Division_Code' value division_code,
                                                            key 'Division_Name' value division_name
                                                returning clob)
                                            returning clob) enrolle_balance
                                        from
                                            fsa_hra_employees_v
                                        where
                                                entrp_id = p_entrp_id
                                            and status <> 'R'
                                            and plan_type = nvl(p_plan_type, plan_type)
                             ----  and rownum < 10
                                            and plan_start_date = p_plan_start_date
                                            and plan_end_date = p_plan_end_date
                                    )
                                returning clob)
                            returning clob)
                        returning clob)
                    returning clob) files
                from
                    enterprise er,
                    account    ac
                where
                        er.entrp_id = p_entrp_id
                    and er.entrp_id = ac.entrp_id
                                                                  --AND   AC.ACCOUNT_STATUS = 1
                group by
                    er.entrp_id,
                    ac.acc_num
            ) loop
                l_clob := j.files;
            end loop;
        end if;

        return l_clob;
    end get_enrolle_balance;

    function get_suspended_card_info (
        p_entrp_id        in number,
        p_plan_type       varchar2,
        p_plan_start_date date,
        p_plan_end_date   date
    ) return clob is
        l_suspended_web clob;
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'dEBIT_CARD_report'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
											--	KEY 'ENTRP_NAME' VALUE ER.NAME,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'EMPLOYER_ADDRESS' value pc_entrp.get_city(p_entrp_id)
                                                                     || ',  '
                                                                     || pc_entrp.get_state(p_entrp_id),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'ENTRP_NAME' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD1' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'ENTRP_PHONE' value entrp_phones,
											--- 	Key 'ACC_NUM' VALUE   PC_ENTRP.get_acc_num (p_entrp_id) , 
                                        key 'STMT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value ac.acc_num,
                                                        key 'NAME' value p.first_name
                                                                         || ' '
                                                                         || last_name,
                                                        key 'FIRST_NAME' value p.first_name,
                                                        key 'LAST_NAME' value p.last_name,
                                                        key 'CARD_NUMBER' value '****-****-****-'
                                                                                || substr(cd.card_number, 13, 4),
                                                        key 'NO_OF_CLAIMS' value(
                                                    select
                                                        count(*)
                                                    from
                                                        claimn c
                                                    where
                                                            c.pers_id = p.pers_id
                                                        and c.unsubstantiated_flag = 'Y'
                                                        and c.pay_reason = 13
                                                ),
                                                        key 'ACC_ID' value ac.acc_id,
                                                        key 'PERS_ID' value p.pers_id,
                                                        key 'DIVISION_CODE' value pc_person.get_division_name(p.pers_id)
                                            returning clob)
                                        returning clob)
                                    from
                                        person     p,
                                        card_debit cd,
                                        enterprise e,
                                        account    ac
                                    where
                                            p.pers_id = cd.card_id
                                        and ac.pers_id = p.pers_id
                                        and p.entrp_id = e.entrp_id
                                        and cd.status in(4, 6)
                                        and p.entrp_id = p_entrp_id
                                        and cd.start_date between p_plan_start_date and p_plan_end_date
                                        and ac.account_type = p_plan_type ---- IN ('HRA','FSA')      
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
          ---    AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_suspended_web := x.files;
        end loop;

        return l_suspended_web;
    end get_suspended_card_info;

    function get_dependent (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob is
        l_dependent_report clob;
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'DEPENDENT'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'EMPLOYER_ADDRESS' value pc_entrp.get_entrp_name(p_entrp_id)
                                                                     || ' , '
                                                                     || pc_entrp.get_state(p_entrp_id)
                                                                     || ',  '
                                                                     || pc_entrp.get_city(p_entrp_id),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'ACCOUNT_NUMBER' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'STMT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'SSN' value replace(a.ssn, '-'),
                                                        key 'SUBSCRIBER_SSN' value replace(d.ssn, '-'),
                                                        key 'NAME' value a.first_name
                                                                         || ' '
                                                                         || a.last_name,
                                                        key 'MIDDLE_NAME' value a.middle_name,
                                                        key 'LAST_NAME' value a.last_name,
                                                        key 'DAY_PHONE' value strip_bad(a.phone_day),
                                                        key 'ADDRESS' value a.address,
                                                        key 'CITY' value a.city,
                                                        key 'STATE' value a.state,
                                                        key 'ZIP' value a.zip,
                                                        key 'BIRTH_DATE' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                                        key 'RELATION' value pc_lookups.get_relat_code(a.relat_code)
                                            )
                                        returning clob)
                                    from
                                        person  a,
                                        person  d,
                                        account b
                                    where
                                            a.pers_main = d.pers_id
                                        and d.entrp_id = p_entrp_id
                                        and d.pers_id = b.pers_id
                                        and exists(
                                            select
                                                *
                                            from
                                                ben_plan_enrollment_setup c
                                            where
                                                    c.acc_id = b.acc_id
                                                and c.status in('P', 'A')
                                        )
                                        and a.pers_end_date is null
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_dependent_report := j.files;
        end loop;

        return l_dependent_report;
    end get_dependent;

    function get_member_list_bill (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return clob is
        l_get_member      clob;
        v_annual_election number;
        l_report_heading  varchar2(250);
    begin
        pc_log.log_error('get_member_list_bill', 'p_entrp_id '
                                                 || p_entrp_id
                                                 || ' p_plan_type '
                                                 || p_plan_type
                                                 || ' p_plan_start_date '
                                                 || p_plan_start_date
                                                 || ' p_plan_end_date '
                                                 || p_plan_end_date);

        select
            sum(c.annual_election)
        into v_annual_election
        from
            person                    a,
            account                   b,
            ben_plan_enrollment_setup c,
            ben_plan_enrollment_setup d,
            scheduler_master          e,
            scheduler_details         f
        where
                a.entrp_id = p_entrp_id
            and e.acc_id (+) = b.acc_id
            and f.acc_id (+) = b.acc_id
            and e.scheduler_id = f.scheduler_id (+)
            and c.ben_plan_id_main = d.ben_plan_id
            and a.pers_id = b.pers_id
            and b.acc_id = c.acc_id
            and c.plan_end_date >= nvl(p_plan_end_date, c.plan_end_date)
            and c.plan_start_date <= nvl(p_plan_start_date, c.plan_start_date);

        l_report_heading := 'Member Census';
        if p_plan_type = 'DCA' then
            l_report_heading := 'DCA Census';
        end if;
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'MEMBER'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'EMPLOYER_ADDRESS' value pc_entrp.get_entrp_name(p_entrp_id)
                                                                     || ' , '
                                                                     || pc_entrp.get_state(p_entrp_id)
                                                                     || ',  '
                                                                     || pc_entrp.get_city(p_entrp_id),
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'ACCOUNT_NUMBER' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'TOTAL_AE' value '$' || to_char(v_annual_election, 'fm9999G990D00'),
                                        key 'REPORT_HEADING' value l_report_heading,
                                        key 'LIST_BILL' value
                                    json_object(
                                        key 'STMT' value(
                                            select
                                                json_arrayagg(
                                                    json_object( 
                                                            --        Key 'TPA_ID' Value CAST(Null as Varchar) TPA_ID,
                                                        key 'sheet_name' value 'Members',
                                                                key 'FIRST_NAME' value a.first_name,
                                                                key 'MIDDLE_NAME' value a.middle_name,
                                                                key 'LAST_NAME' value a.last_name,
                                                                key 'SSN' value replace(a.ssn, '-'),
                                                                key 'EE_ACC_NUM' value b.acc_num,
                                                                key 'ACTION' value null,
                                                                key 'GENDER' value a.gender,
                                                                key 'ADDRESS' value a.address,
                                                                key 'CITY' value a.city,
                                                                key 'STATE' value a.state,
                                                                key 'ZIP' value a.zip,
                                                                key 'PHONE' value strip_bad(a.phone_day),
                                                                key 'EMAIL' value a.email,
                                                                key 'DOB' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                                                key 'DIV_CODE' value a.division_code,
                                                                key 'PLAN_TYPE' value c.plan_type,
                                                                key 'EFFECTIVE_DATE' value to_char(c.effective_date, 'MM/DD/YYYY'),
                                                                key 'FIRST_PAYROLL_DATE' value to_char(e.payment_start_date, 'mm/dd/yyyy'
                                                                ),
                                                                key 'PAYROLL_CYCLE' value e.recurring_frequency,
                                                                key 'NOPP' value cast(null as number),
                                                                --    Key 'ANN_ELECT' Value     '$'||TO_CHAR(nvl(C.ANNUAL_ELECTION,0),'fm9999G990D00'),
                                                                key 'ANN_ELECT' value nvl(c.annual_election, 0),
                                                                key 'PER_PAY_PERIOD_CONTRIBUTION' value '$'
                                                                                                        || to_char(
                                                            nvl(f.er_amount, 0),
                                                            'fm9999G990D00'
                                                        ),
                                                                key 'DEBIT_CARD' value decode(
                                                            pc_entrp.card_allowed(p_entrp_id),
                                                            0,
                                                            'No',
                                                            ' Yes'
                                                        ),
                                                                key 'DEDUCTIBLE' value pc_benefit_plans.get_deductible(c.ben_plan_id_main
                                                                , b.acc_id),
                                                                key 'COVERAGE' value pc_benefit_plans.get_cov_tier_name(c.ben_plan_id_main
                                                                , b.acc_id),
                                                                key 'TERM_DATE' value to_char(c.effective_end_date, 'MM/DD/YYYY'),
                                                                key 'PLAN_CODE' value(
                                                            select
                                                                plan_name
                                                            from
                                                                plan_codes
                                                            where
                                                                plan_code = b.plan_code
                                                        ),
                                                                key 'GROUP_NUMBER' value b.acc_num,
                                                                key 'EMPLOYEE_ID' value a.pers_id,
                                                                key 'QUALIFYING_EVENT' value null,
                                                                key 'FUNDING_TYPE' value c.ben_plan_id,
                                                                key 'NOTES' value null,
                                                                key 'DIVISION_NAME' value pc_person.get_division_name(a.pers_id),
                                                                key 'PLAN_START_DATE' value to_char(c.plan_start_date, 'MM/DD/YYYY'),
                                                                key 'PLAN_END_DATE' value to_char(c.plan_end_date, 'MM/DD/YYYY'),
                                                                key 'BEN_PLAN_ID' value c.ben_plan_id,
                                                                key 'ACCOUNT_ID' value c.acc_id,
                                                                key 'ACCOUNT_NUMBER' value b.acc_num,
                                                                key 'INVOICE_TYPE' value decode(d.claim_reimbursed_by, 'EMPLOYER', 'CLAIM_INVOICE'
                                                                , 'FUNDING_INVOICE'),
                                                                key 'ER_AMT' value nvl(f.er_amount, 0),
                                                                key 'SCHEDULER_ID' value e.scheduler_id
                                                    )
                                                returning clob)
                                            from
                                                person                    a,
                                                account                   b,
                                                ben_plan_enrollment_setup c,
                                                ben_plan_enrollment_setup d,
                                                scheduler_master          e,
                                                scheduler_details         f
                                            where
                                                    a.entrp_id = p_entrp_id
                                                and e.acc_id(+) = b.acc_id
                                                and f.acc_id(+) = b.acc_id
                                                and e.scheduler_id = f.scheduler_id(+)
                                                     --- And  Payment_End_Date   <=   P_Plan_End_Date   ---  OR  P_Plan_Type   IN ('TRN',  'PKG')
                                                   ---   And  Payment_Start_Date >=   P_Plan_Start_Date  ---  OR  P_Plan_Type   IN ('TRN',  'PKG'))
                                                      ---  And   e.Plan_Type    = Nvl(P_Plan_Type , e.Plan_Type)
                                                    --    And   f.STATUS = 'A'
                                                and c.ben_plan_id_main = d.ben_plan_id
                                                and a.pers_id = b.pers_id
                                                and b.acc_id = c.acc_id
                                                and((p_plan_type = 'HRA'
                                                     and c.product_type = 'HRA')
                                                    or c.plan_type in('FSA', 'DCA'))
                                                and c.status = 'A'
                                                and d.status = 'A'
                                                and c.plan_end_date >= nvl(p_plan_end_date, c.plan_end_date)
                                                and c.plan_start_date <= nvl(p_plan_start_date, c.plan_start_date)
                                        ),
                                                key 'DSTMT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'sheet_name' value 'Dependent',
                                                                key 'SSN' value replace(a.ssn, '-'),
                                                                key 'SUBSCRIBER_SSN' value replace(d.ssn, '-'),
                                                                key 'SUBSCRIBER_NAME' value d.full_name,
                                                                key 'NAME' value a.first_name
                                                                                 || ' '
                                                                                 || a.last_name,
                                                                key 'MIDDLE_NAME' value a.middle_name,
                                                                key 'LAST_NAME' value a.last_name,
                                                                key 'DAY_PHONE' value strip_bad(a.phone_day),
                                                                key 'ADDRESS' value a.address,
                                                                key 'CITY' value a.city,
                                                                key 'STATE' value a.state,
                                                                key 'ZIP' value a.zip,
                                                                key 'BIRTH_DATE' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                                                key 'RELATION' value pc_lookups.get_relat_code(a.relat_code)
                                                    )
                                                returning clob)
                                            from
                                                person  a,
                                                person  d,
                                                account b
                                            where
                                                    a.pers_main = d.pers_id
                                                and d.entrp_id = p_entrp_id
                                                and d.pers_id = b.pers_id
                                                and exists(
                                                    select
                                                        *
                                                    from
                                                        ben_plan_enrollment_setup c
                                                    where
                                                            c.acc_id = b.acc_id
                                                        and c.status in('P', 'A')
                                                )
                                                and a.pers_end_date is null
                                        )
                                    returning clob)
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id   --- NVL(p_entrp_id ,ER.ENTRP_ID)
                and er.entrp_id = ac.entrp_id
           ---   AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_get_member := j.files;
        end loop;

   ---    End if; 
        return l_get_member;
    end get_member_list_bill;

    function get_debit_card_swipes_info (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_division_code   in varchar2
    ) return clob is
        l_card_swipes_web clob;
        l_sum_claim       number := 0;
        l_sum_approved    number := 0;
    begin
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'DEBIT_CARD_SWIPES'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'PROC_DATE' value to_char(sysdate, 'Day ddth ')
                                                              || trim(to_char(sysdate, 'Month'))
                                                              || to_char(sysdate, ' YYYY HH12:MI:SS AM'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'ER_ACC_NUM' value pc_entrp.get_acc_num(p_entrp_id),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'CLAIM_TOT' value '$'
                                                              || to_char(
                                    nvl(l_sum_claim, 0),
                                    'fm9999G990D00'
                                ),
                                        key 'APPR_TOT' value '$'
                                                             || to_char(
                                    nvl(l_sum_approved, 0),
                                    'fm9999G990D00'
                                ),
                                        key 'EMP_ADDR1' value er.address,
                                        key 'ENTRP_PHONE' value er.entrp_phones,
                                        key 'EMP_ADDR2' value er.city
                                                              || ', '
                                                              || er.state
                                                              || ' '
                                                              || er.zip,
                                        key 'ST_ADDRESS' value pc_web_utility_pkg.get_sterling_address1
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_city
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_state
                                                               || ', '
                                                               || pc_web_utility_pkg.get_sterling_zip,
                                        key 'DEBIT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'ACC_NUM' value a.acc_num,
                                                        key 'NAME' value a.first_name
                                                                         || ' '
                                                                         || a.last_name,
                                                        key 'FIRST_NAME' value a.first_name,
                                                        key 'LAST_NAME' value a.last_name,
                                                        key 'DIV_NAME' value division_name,
                                                        key 'SUBS' value decode(
                                                    nvl(substantiated, 'Y'),
                                                    'Y',
                                                    'No',
                                                    'Yes'
                                                ),
                                                        key 'CLAIM_AMT' value '$'
                                                                              || to_char(
                                                    nvl(claim_amount, 0),
                                                    'fm9999G990D00'
                                                ),
                                                        key 'APPR_AMT' value nvl(approved_amount, 0), -- '$'||TO_CHAR(nvl(APPROVED_AMOUNT,0),'fm9999G990D00') , 
                                                        key 'OFF_AMT' value nvl(amount_remaining_for_offset, 0),  -- '$'||TO_CHAR(nvl(AMOUNT_REMAINING_FOR_OFFSET,0),'fm9999G990D00')    	 , 
                                                        key 'TRAN_DATE' value to_char(claim_date, 'mm/dd/yyyy'),
                                                        key 'CLAIM_NUM' value claim_id,
                                                        key 'CLAIM_CAT' value service_type_meaning,
                                                        key 'PLAN_TYPE' value service_type
                                            returning clob)
                                        returning clob)
                                    from
                                        hrafsa_debit_card_claims_v a
                                    where
                                            entrp_id = p_entrp_id
                                        and ac.entrp_id = a.entrp_id
                                        and trunc(plan_start_date) = trunc(p_plan_start_date)
                                        and trunc(plan_end_date) = trunc(p_plan_end_date)
                                        and trunc(claim_date) between p_start_date and p_end_date
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
        --    AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_card_swipes_web := x.files;
        end loop;

        return l_card_swipes_web;
    end get_debit_card_swipes_info;

-- VANITHA TO HARI : IF NOT USED REMOVE IT 

    function get_claims_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob is

        l_contrib_clob  clob;
        l_division_code varchar2(10);
        l_record        pc_office_reports.plan_type_totals_t;
        l_ctr           number := 0; 
/*
    l_SUM_ER string_asc_arr_t;
    l_SUM_EE string_asc_arr_t;
    l_SUM_all string_asc_arr_t;
    l_GSUM_ER string_asc_arr_t;
    l_GSUM_EE string_asc_arr_t;
    l_GSUM_all string_asc_arr_t; */
        l_sum_er        number := 0;
        l_sum_ee        number := 0;
        l_sum_all       number := 0;
        l_idx           varchar2(50);
        l_all_types     varchar2(1000);
    begin
        for i in (
            select
                plan_type,
                sum(er_amount)             sum_er,
                sum(ee_amount)             sum_ee,
                sum(ee_amount + er_amount) sum_all
            from
                ee_deposits_v
            where
                    fee_date >= p_plan_start_date
                and fee_date <= p_plan_end_date
                and entrp_id = p_entrp_id
            group by
                plan_type
            order by
                plan_type
        ) loop
            l_all_types := l_all_types || i.plan_type;
            l_sum_er := i.sum_er + l_sum_er;
            l_sum_ee := l_sum_ee + i.sum_ee;
            l_sum_all := l_sum_all + l_sum_ee + l_sum_er;
        end loop;

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Contribution_Aggregated_'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'START_DATE' value to_char(p_plan_start_date, 'MM/DD/YYYY'),
                                        key 'END_DATE' value to_char(p_plan_end_date, 'MM/DD/YYYY'),
                                        key 'S_EE_AMT' value '$' || to_char(l_sum_ee, 'fm9999G990D00'),
                                        key 'S_ER_AMT' value '$' || to_char(l_sum_er, 'fm9999G990D00'),
                                        key 'S_ALL_AMT' value '$' || to_char(l_sum_all, 'fm9999G990D00'),
                                        key 'ACC_NUM' value ac.acc_num,
                                        key 'ER_ADD1' value pc_entrp.get_entrp_name(p_entrp_id),
                                        key 'ER_ADD2' value pc_entrp.get_city(p_entrp_id),
                                        key 'ER_ADD3' value pc_entrp.get_state(p_entrp_id)
                                                            || ' - '
                                                            || er.zip,
                                        key 'EMPLOYER' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PL_DET' value(
                                                    select
                                                        json_arrayagg(
                                                            json_object(
                                                                key 'PLAN_TYPE' value a.plan_type,
                                                                        key 'DIVISION_NAME' value division_name,
                                                                        key 'ACC_NUM' value a.acc_num,
                                                                        key 'FULL_NAME' value name,
                                                                        key 'EE_AMOUNT' value '$'
                                                                                              || to_char(
                                                                    sum(a.ee_amount),
                                                                    'fm9999G990D00'
                                                                ),
                                                                        key 'ER_AMOUNT' value '$'
                                                                                              || to_char(
                                                                    sum(a.er_amount),
                                                                    'fm9999G990D00'
                                                                ),
                                                                        key 'T_AMT' value '$'
                                                                                          || to_char(
                                                                    sum(ee_amount + er_amount),
                                                                    'fm9999G990D00'
                                                                )
                                                            returning clob)
                                                        returning clob)
                                                    from
                                                        ee_deposits_v a
                                                    where
                                                            a.fee_date >= to_date(p_plan_start_date, 'MM/DD/YYYY')
                                                        and a.fee_date <= to_date(p_plan_end_date, 'MM/DD/YYYY')
                                                        and s.lookup_code = a.plan_type
                                                        and a.entrp_id = p_entrp_id
                                                    group by
                                                        a.plan_type,
                                                        division_name,
                                                        a.acc_num,
                                                        name
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select
                                                lookup_code
                                            from
                                                lookups
                                            where
                                                lookup_name = 'FSA_PLAN_TYPE'
                                        ) s
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
          ---    AND   AC.ACCOUNT_STATUS = 1
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_contrib_clob := j.files;
        end loop;

        return l_contrib_clob;
    end get_claims_type;

    procedure run_claim_invoice (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.acc_num                         acc_num,
                ar.invoice_id,
                json_query(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
                           '$.data[0]')            claim_inv,
                json_value(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
                           '$.data[0].ENTRP_CODE') entrp_code,
                json_value(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
                           '$.filename')           filename,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value json_value(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
           '$.data[0].ENTRP_NAME'),
                                key 'INVOICE_PERIOD' value json_value(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
           '$.data[0].INVOICE_PERIOD'),
                                key 'INVOICE_DUE_DATE' value json_value(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
           '$.data[0].INVOICE_DUE_DATE'),
                                key 'PLAN_TYPE' value json_value(pc_office_reports.get_hra_fsa_invoice(ar.invoice_id),
           '$.data[0].PLAN_TYPE'),
                                key 'ACC_NUM' value acc.acc_num
                    )
                place_holder
            from
                ar_invoice ar,
                account    acc
            where
                    ar.acc_id = acc.acc_id
                and ar.invoice_reason = 'CLAIM'
                and ar.invoice_id = nvl(p_invoice_id, invoice_id)
                and ( p_invoice_id is not null
                      or ( p_invoice_id is null
                           and trunc(ar.creation_date) = trunc(sysdate) ) )
        ) loop
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => i.claim_inv,
                    p_template_type   => 'APEX',
                    p_template_source => q'[HRA_FSA_Claim_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                       -- p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

           /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'CLAIM_BILLING', 'HRAFSA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'CLAIMINVOICEACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_claim_invoice;

    function get_hra_fsa_invoice (
        p_invoice_id in number
    ) return clob is
        l_hra_fsa_det clob;
        v_subtotal    number;
        v_par_reim    number;
        v_pro_pay     number;
        v_deb_pay     number;
        v_tot_pay     number;
    begin
        begin
            select
                sum(ali.total_line_amount)
            into v_subtotal
            from
                ar_invoice_lines ali
            where
                ali.invoice_id = p_invoice_id;

            select
                nvl(
                    sum(
                        case
                            when reimbursement_method = 'Debit Card Purchase' then
                                check_amount
                        end
                    ),
                    0
                ),
                nvl(
                    sum(
                        case
                            when reimbursement_method = 'To Provider' then
                                check_amount
                        end
                    ),
                    0
                ),
                nvl(
                    sum(
                        case
                            when reimbursement_method not in('Debit Card Purchase', 'To Provider') then
                                check_amount
                        end
                    ),
                    0
                )
            into
                v_deb_pay,
                v_pro_pay,
                v_par_reim
            from
                table ( pc_invoice.get_claim_invoice(p_invoice_id) );

            v_tot_pay := v_deb_pay + v_pro_pay + v_par_reim;
        exception
            when no_data_found then
                v_tot_pay := 0;
        end;

        select
            json_arrayagg(
                json_object(
                    key 'filename' value a.invoice_id,
                            key 'data' value(
                        select
                            json_arrayagg(
                                json_object(
                                    key 'DEB_PAY' value format_money(v_deb_pay),
                                            key 'PRO_PAY' value format_money(v_pro_pay),
                                            key 'PAR_REIM' value format_money(v_par_reim),
                                            key 'TOT_PAY' value format_money(v_tot_pay),
                                            key 'INVOICE_ID' value ar.invoice_id,
                                            key 'ENTRP_ID' value er.entrp_id,
                                            key 'ENTRP_CODE' value er.entrp_code,
                                            key 'AUTO_PAY' value ar.auto_pay,
                                            key 'PAYMENT_METHOD' value ar.payment_method,
                                            key 'INV_AMOUNT' value ar.invoice_amount,
                                            key 'ACC_NUM' value ar.acc_num,
                                            key 'ENTRP_NAME' value er.name,
                                            key 'ADDRESS1' value er.address,
                                            key 'ADDRESS2' value er.city
                                                                 || ',  '
                                                                 || er.state
                                                                 || ',  '
                                                                 || er.zip,
                                            key 'INVOICE_AMOUNT' value '$'
                                                                       || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)),
                                                                                  'fm9999G990D00'),
                                            key 'PAID_AMOUNT' value '$'
                                                                    || to_char(ar.paid_amount, 'fm9999G990D00'),
                                            key 'CUR_BAL_DUE' value '$'
                                                                    || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)) - ar.paid_amount
                                                                    ,
                                                                               'fm9999G990D00'),
                                            key 'BAL_DUE' value '$'
                                                                || to_char(
                                        nvl(
                                            pc_invoice.get_outstanding_balance(er.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                            ),
                                            0
                                        ),
                                        'fm9999G990D00'
                                    ),
                                            key 'TOTAL_DUE' value '$'
                                                                  || to_char(nvl(ar.pending_amount, 0) + nvl(
                                        pc_invoice.get_outstanding_balance(er.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                        ),
                                        0
                                    ),
                                                                             'fm9999G990D00'),
                                            key 'INVOICE_NUMBER' value ar.invoice_number,
                                            key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                            key 'PLAN_TYPE' value plan_type,
                                            key 'INVOICE_DUE_DATE' value to_char(ar.invoice_due_date, 'MM/DD/YYYY'),
                                            key 'INVOICE_PERIOD' value to_char(start_date, 'MM/DD/YYYY')
                                                                       || '-'
                                                                       || to_char(end_date, 'MM/DD/YYYY'),
                                            key 'SUB_TOTAL' value '$'
                                                                  || to_char((
                                        select
                                            sum(ali.total_line_amount)
                                        from
                                            ar_invoice_lines ali
                                        where
                                            ali.invoice_id = ar.invoice_id
                                    ),
                                                                             'fm9999G990D00'),
                                            key 'NOTE' value
                                        case
                                            when invoice_amount > 0
                                                 and auto_pay = 'Y'
                                                 and payment_method = 'DIRECT_DEPOSIT' then
                                                '**** Payment by ACH '
                                                || format_money(invoice_amount)
                                                || ' scheduled on '
                                                || to_char(invoice_due_date, 'MM/DD/YYYY')
                                                || ' No remittance necessary****'
                                            else
                                                ''
                                        end,

                          --          KEY 'OUTPUT_MERGE'      VALUE       'true',
                                            key 'TOTALS' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'DEB_PAY' value to_char(
                                                        nvl(
                                                            sum(
                                                                case
                                                                    when reimbursement_method = 'Debit Card Purchase' then
                                                                        check_amount
                                                                end
                                                            ),
                                                            0
                                                        ),
                                                        'fm9999G990D00'
                                                    ),
                                                            key 'PRO_PAY' value to_char(
                                                        nvl(
                                                            sum(
                                                                case
                                                                    when reimbursement_method = 'To Provider' then
                                                                        check_amount
                                                                end
                                                            ),
                                                            0
                                                        ),
                                                        'fm9999G990D00'
                                                    ),
                                                            key 'PAR_REIM' value to_char(
                                                        nvl(
                                                            sum(
                                                                case
                                                                    when reimbursement_method not in('Debit Card Purchase', 'To Provider'
                                                                    ) then
                                                                        check_amount
                                                                end
                                                            ),
                                                            0
                                                        ),
                                                        'fm9999G990D00'
                                                    )
                                                returning clob)
                                            returning clob)
                                        from
                                            table(pc_invoice.get_claim_invoice(ar.invoice_id))
                                        group by
                                            reimbursement_method
                                    ),
                                            key 'CLAIM_SUMMARY' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'DESCRIPTION' value al.description,
                                                            key 'INV_AMOUNT' value '$'
                                                                                   || to_char(al.total_line_amount, 'fm9999G990D00')
                                                returning clob)
                                            returning clob)
                                        from
                                            ar_invoice_lines al
                                        where
                                                al.invoice_id = ar.invoice_id
                                            and al.status not in('VOID', 'CANCELLED')
                                    ),
                                            key 'PLAN_DET' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'PLAN_TYPE' value plan_type,
                                                    key 'PLAN_TYPE_MEANING' value plan_type_meaning
                                                returning clob)
                                            returning clob)
                                        from
                                            (
                                                select distinct
                                                    plan_type,
                                                    plan_type_meaning
                                                from
                                                    fsa_hra_er_ben_plans_v plans_v
                                                where
                                                    plans_v.entrp_id = er.entrp_id
                                            )
                                    ),
                                            key 'STMT' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'ACC_NUM' value x.acc_num,
                                                            key 'EMP_NAME' value x.name,
                                                            key 'DIV_NAME' value x.division_name,
                                                            key 'CLAIM_NUMBER' value x.transaction_number,
                                                            key 'PLAN' value x.service_type_meaning,
                                                            key 'CLAIM_AMOUNT' value '$'
                                                                                     || to_char(x.claim_amount, 'fm9999G990D00'),
                                                            key 'APP_AMOUNT' value '$'
                                                                                   || to_char(x.approved_amount, 'fm9999G990D00'),
                                                            key 'PAY_AMOUNT' value '$'
                                                                                   || to_char(x.check_amount, 'fm9999G990D00'),
                                                            key 'REIM_BY' value x.reimbursement_method,
                                                            key 'PLAN_YR' value x.plan_year
                                                returning clob)
                                            returning clob)
                                        from
                                            table(pc_invoice.get_claim_invoice(ar.invoice_id)) x
                                    )
                                returning clob)
                            returning clob)
                        from
                            ar_invoice ar,
                            enterprise er
                        where
                                ar.invoice_id = a.invoice_id
                            and ar.invoice_reason = 'CLAIM'
                            and ar.entity_id = er.entrp_id
                    )
                returning clob)
            returning clob)
        into l_hra_fsa_det
        from
            ar_invoice a
        where
            ( ( a.invoice_id = p_invoice_id
                and p_invoice_id is not null )
              or ( p_invoice_id is null
                   and trunc(a.creation_date) = trunc(sysdate) ) )
            and a.invoice_reason = 'CLAIM';

        if length(l_hra_fsa_det) = 0
        or l_hra_fsa_det is null then
            select
                json_arrayagg(
                    json_object(
                        key 'data' value ''
                    )
                )
            into l_hra_fsa_det
            from
                dual;

        end if;

        return l_hra_fsa_det;
    end get_hra_fsa_invoice;

    procedure run_invoice_pdf (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.invoice_id,
                acc.acc_num                                                             acc_num,
                ar.division_code,
                c.entrp_code                                                            entrp_code,
                pc_employer_divisions.get_division_name(ar.division_code, acc.entrp_id) division_name,
                json_query(pc_office_reports.get_fee_invoice(ar.invoice_id),
                           '$.data[0]')                                                 pdf_inv,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value c.name,
                                key 'INVOICE_PERIOD' value to_char(ar.start_date, 'MM/DD/YYYY')
                                                           || '-'
                                                           || to_char(ar.end_date, 'MM/DD/YYYY'),
                                key 'INVOICE_DUE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                key 'ACC_NUM' value acc.acc_num
                    )
                place_holder
            from
                ar_invoice ar,
                account    acc,
                enterprise c
            where
                    ar.invoice_id = nvl(p_invoice_id, invoice_id)
                and ar.acc_id = acc.acc_id
                and ar.status in ( 'GENERATED', 'PROCESSED' )
                and ar.invoice_reason = 'FEE'
                and ( trunc(ar.approved_date) = trunc(sysdate)
                      or trunc(ar.creation_date) >= trunc(sysdate, 'MM') )
                and ar.entity_id = c.entrp_id
        ) loop
            dbms_output.put_line(i.pdf_inv);
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => i.pdf_inv,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Fee_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
             --           p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

            /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'FEE_BILLING', 'HRAFSA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'INVOICEPDFACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_invoice_pdf;

    procedure run_invoice_notify (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.invoice_id           invoice_id,
                acc.acc_num             acc_num,
                c.entrp_code            entrp_code,
                json_query(pc_office_reports.get_fee_invoice(ar.invoice_id),
                           '$.data[0]') notify_inv,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value c.name,
                                key 'INVOICE_PERIOD' value to_char(ar.start_date, 'MM/DD/YYYY')
                                                           || '-'
                                                           || to_char(ar.end_date, 'MM/DD/YYYY'),
                                key 'INVOICE_DUE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                key 'ACC_NUM' value acc.acc_num
                    )
                place_holder
            from
                ar_invoice    ar,
                account       acc,
                enterprise    c,
                general_agent ga
            where
                    ar.acc_id = acc.acc_id
                and ar.status <> 'VOID'
                and ar.invoice_reason = 'FEE'
                and ar.mailed_date is null
                and acc.account_type in ( 'HRA', 'FSA' )
                and trunc(ar.approved_date) >= trunc(sysdate, 'MM')
                and acc.ga_id = ga.ga_id (+)
                and nvl(ga.generate_combined_stmt, 'N') = 'N'
                and ar.entity_id = c.entrp_id
            order by
                invoice_id
        ) loop
            dbms_output.put_line(i.notify_inv);
            dbms_output.put_line(i.place_holder);
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => i.notify_inv,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Fee_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
             --           p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

            /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'FEE_BILLING', 'HRAFSA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'INVOICEPDFACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_invoice_notify;

    procedure run_invoice_poperisa5500 (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.invoice_id           invoice_id,
                acc.acc_num             acc_num,
                c.entrp_code            entrp_code,
                acc.account_type        account_type,
                json_query(pc_office_reports.get_erisa500_invoice(ar.invoice_id),
                           '$.data[0]') poperisa_inv,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value c.name,
                                key 'INVOICE_PERIOD' value to_char(ar.start_date, 'MM/DD/YYYY')
                                                           || '-'
                                                           || to_char(ar.end_date, 'MM/DD/YYYY'),
                                key 'INVOICE_DUE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                key 'ACC_NUM' value acc.acc_num
                    )
                place_holder
            from
                ar_invoice         ar,
                account            acc,
                invoice_parameters ip,
                enterprise         c
            where
                    ar.invoice_id = nvl(p_invoice_id, invoice_id)
                and ar.acc_id = acc.acc_id
                and ip.entity_id = acc.entrp_id
                and ip.entity_type = 'EMPLOYER'
                and ar.rate_plan_id = ip.rate_plan_id
                and ip.status = 'A'
                and ip.invoice_type = 'FEE'
                and acc.account_type = 'COBRA'
                and trunc(ar.approved_date) >= trunc(sysdate) - 1
                and mailed_date is null
                and ar.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                and ar.entity_id = c.entrp_id
        ) loop
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => i.poperisa_inv,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Fee_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
            --            p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

            /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'FEE_BILLING', 'COBRA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'INVOICEPDFACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_invoice_poperisa5500;

    procedure run_invoice_collection (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.invoice_id    invoice_id,
                acc.acc_num      acc_num,
                c.entrp_code     entrp_code,
                acc.account_type account_type,
                case
                    when acc.account_type in ( 'HRA', 'FSA' ) then
                        json_query(pc_office_reports.get_fee_invoice(ar.invoice_id),
                                   '$.data[0]')
                    else
                        json_query(pc_office_reports.get_erisa500_invoice(ar.invoice_id),
                                   '$.data[0]')
                end              collect_inv,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value c.name,
                                key 'INVOICE_PERIOD' value to_char(ar.start_date, 'MM/DD/YYYY')
                                                           || '-'
                                                           || to_char(ar.end_date, 'MM/DD/YYYY'),
                                key 'INVOICE_DUE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                key 'ACC_NUM' value acc.acc_num
                    )
                place_holder
            from
                ar_invoice_notifications ain,
                email_notifications      en,
                ar_invoice               ar,
                account                  acc,
                enterprise               c
            where
                    ain.notification_id = en.notification_id
                and ain.mailed_date is null
                and ar.invoice_id = ain.invoice_id
                and acc.acc_num = ar.acc_num
                and en.mail_status = 'OPEN'
                and ain.template_name in ( 'INVOICE_URGENT_NOTICE', 'INVOICE_FINAL_NOTICE', 'INVOICE_COURTESY_NOTICE' )
                and ar.entity_id = c.entrp_id
        ) loop
            dbms_output.put_line(i.collect_inv);
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => i.collect_inv,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Fee_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
            --            p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

            /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'FEE_BILLING', 'HRAFSA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'INVOICEPDFACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_invoice_collection;

    function get_fee_invoice (
        p_invoice_id in number
    ) return clob is
        l_invoice_det    clob;
        v_pay_cont_total number;
        v_cnt            number;
    begin
        select
            count(1)
        into v_cnt
        from
            ar_invoice_v
        where
                invoice_id = p_invoice_id
            and invoice_reason = 'FEE';

        if v_cnt > 0 then
            select
                nvl(
                    sum(al.total_line_amount),
                    0
                )
            into v_pay_cont_total
            from
                ar_invoice_v                 ar,
                ar_invoice_lines             al,
                invoice_distribution_summary ds,
                account                      ac,
                person                       pe
            where
                    ar.invoice_id = p_invoice_id
                and ar.invoice_reason = 'FEE'
                and ar.status_code not in ( 'VOID', 'CANCELLED' )
                and ar.invoice_id = al.invoice_id
                and ar.invoice_id = ds.invoice_id
                and ds.invoice_line_id = al.invoice_line_id
                and ds.pers_id = ac.pers_id
                and ds.pers_id = pe.pers_id;

            select
                json_arrayagg(
                    json_object(
                        key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'INVOICE_ID' value ar.invoice_id,
                                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'INVOICE_NUMBER' value ar.invoice_number,
                                                key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                                key 'INVOICE_PERIOD' value ar.coverage_period,
                                                key 'ACCOUNT_NUMBER' value ar.acc_num,
                                                key 'ACCOUNT_TYPE' value ar.account_type,
                                                key 'EMPLOYER_ADDRESS' value ar.billing_name
                                                                             || chr(10)
                                                                             || 'Attn: '
                                                                             || ar.billing_attn
                                                                             || chr(10)
                                                                             || ar.billing_address
                                                                             || chr(10)
                                                                             || ar.billing_city
                                                                             || ', '
                                                                             || ar.billing_state
                                                                             || ar.billing_zip,
                                                key 'INVOICE_AMOUNT' value '$'
                                                                           || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)),
                                                                                      'fm9999G990D00'),
                                                key 'PAID_AMOUNT' value '$'
                                                                        || to_char(ar.paid_amount, 'fm9999G990D00'),
                                                key 'PAY_RECVD' value '$'
                                                                      || to_char(ar.paid_amount, 'fm9999G990D00'),
                                                key 'CUR_BAL_DUE' value '$'
                                                                        || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)) - ar.paid_amount
                                                                        ,
                                                                                   'fm9999G990D00'),
                                                key 'BAL_DUE' value '$'
                                                                    || to_char(
                                            nvl(
                                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                                ),
                                                0
                                            ),
                                            'fm9999G990D00'
                                        ),
                                                key 'OUT_BAL' value '$'
                                                                    || to_char(
                                            nvl(
                                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                                ),
                                                0
                                            ),
                                            'fm9999G990D00'
                                        ),
                                                key 'TOTAL_DUE' value '$'
                                                                      || to_char(nvl(ar.pending_amount, 0) + nvl(
                                            pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                            ),
                                            0
                                        ),
                                                                                 'fm9999G990D00'),
                                                key 'PLAN_TYPE' value ar.plan_type,
                                                key 'PAYMENT_MSG' value ar.invoice_term,
                                                key 'COMMENTS' value
                                            case
                                                when ar.plan_type in('HRA', 'FSA', 'HRAFSA')
                                                     and ar.invoice_reason = 'FEE' then
                                                    'Note: Sterling''s FSA and HRA Monthly Administrative Fee Minimum is $125'
                                                else
                                                    ar.comments
                                            end,
                                                key 'PAY_CONT_TOTAL' value '$'
                                                                           || to_char(
                                            nvl(v_pay_cont_total, 0),
                                            'fm9999G990D00'
                                        ),
                                                key 'ENTRP_CODE' value ar.entrp_id,
                                                key 'PENDING_AMOUNT' value ar.pending_amount,
                                                key 'PAYMENT_METHOD' value ar.payment_method,
                                                key 'EMPLOYER_NAME' value ar.employer_name,
                                                key 'INVOICE_STATUS' value ar.invoice_status,
                                                key 'INVOICE_TERM' value ar.invoice_term,
                                                key 'ENTRP_ID' value ar.entrp_id,
                                                key 'DIVISION_CODE' value ar.division_code,
                    /* KEY 'INVOICE_LINES_ERISA500' VALUE NULL, */
                                                key 'INVOICE_LINES_FEE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'INVOICE_LINE_ID' value al.invoice_line_id,
                                                                key 'DESCRIPTION' value al.description,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00'),
                                                                key 'NO_OF_MONTHS' value al.no_of_months,
                                                                key 'INVOICE_LINE_AMOUNT' value '$'
                                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00'
                                                                                                ),
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              )
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al
                                            where
                                                al.invoice_id = p_invoice_id
                                        ),
                                                key 'PAY_CONT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'INVOICE_LINE_ID' value ds.invoice_line_id,
                                                                key 'DESCRIPTION' value al.description,
                                                                key 'NO_OF_MONTHS' value al.no_of_months,
                                                                key 'ACC_NUM' value ac.acc_num,
                                                                key 'EMP_NAME' value pe.full_name,
                                                                key 'UNIT_RATE_COST' value '$'
                                                                                           || to_char(al.unit_rate_cost, 'fm9999G990D00'
                                                                                           ),
                                                                key 'DIVISION_NAME' value pc_person.get_division_name(pe.pers_id),
                                                                key 'PLAN' value pc_lookups.get_fsa_plan_type(ds.plans),
                                                                key 'CONTRIBUTION' value '$'
                                                                                         || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                         )
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines             al,
                                                invoice_distribution_summary ds,
                                                account                      ac,
                                                person                       pe
                                            where
                                                    ds.invoice_id = p_invoice_id
                                                and ds.invoice_line_id = al.invoice_line_id
                                                and ds.pers_id = ac.pers_id
                                                and ds.pers_id = pe.pers_id
                                        ),
                                                key 'FSA_ACTIVE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type in('ACTIVE', 'CARD', 'OTHERS', 'NEW_ENROLLMENT', 'ADD_TERM',
                                                                         'TERMINATION')
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type <> 'HRA'
                                                    or al.product_type is null)
                                        ),
                                                key 'HRA_ACTIVE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type in('ACTIVE', 'CARD', 'OTHERS', 'NEW_ENROLLMENT', 'ADD_TERM',
                                                                         'TERMINATION')
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type = 'HRA')
                                        ),
                                                key 'FSA_RUNOUT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type = 'RUNOUT'
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type <> 'HRA'
                                                    or al.product_type is null)
                                        ),
                                                key 'HRA_RUNOUT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type = 'RUNOUT'
                                                and al.rate_code = to_char(b.reason_code)
                                                and al.product_type = 'HRA'
                                        ),
                                                key 'FSA_ADJUSTMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type = 'ADJUSTMENT'
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type <> 'HRA'
                                                    or al.product_type is null)
                                        ),
                                                key 'HRA_ADJUSTMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type = 'ADJUSTMENT'
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type = 'HRA')
                                        ),
                                                key 'FSA_TERMINATION' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type = 'TERMINATION'
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type <> 'HRA'
                                                    or al.product_type is null)
                                        ),
                                                key 'HRA_TERMINATION' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type = 'TERMINATION'
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type = 'HRA')
                                        ),
                                                key 'HRA_FLATFEE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type in('FLAT_FEE', 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE'
                                                )
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type = 'HRA')
                                        ),
                                                key 'FSA_FLATFEE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              ),
                                                                key 'TOTAL_C' value al.total_line_amount,
                                                                key 'NO_OF_MONTHS' value
                                                            case
                                                                when invoice_line_type not in('SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE'
                                                                ) then
                                                                    round(nvl(total_line_amount, 0) /(quantity * unit_rate_cost))
                                                                else
                                                                    1
                                                            end,
                                                                key 'INVOICE_LINE_TYPE' value invoice_line_type,
                                                                key 'CALCULATION_TYPE' value calculation_type,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al,
                                                pay_reason       b
                                            where
                                                    al.invoice_id = ar.invoice_id
                                                and al.status not in('VOID', 'CANCELLED')
                                                and invoice_line_type in('FLAT_FEE', 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE'
                                                )
                                                and al.rate_code = to_char(b.reason_code)
                                                and(al.product_type <> 'HRA'
                                                    or al.product_type is null)
                                        ),
                                                key 'FSA_ACTIVE_ADJUSTMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'PERS_NAME' value p.last_name
                                                                              || ','
                                                                              || p.first_name,
                                                                key 'DESCRIPTION' value d.reason_name,
                                                                key 'ENROLLED_DATE' value to_char(a.enrolled_date, 'MM/DD/YYYY'),
                                                                key 'EFFECTIVE_DATE' value to_char(a.effective_date, 'MM/DD/YYYY'),
                                                                key 'UNIT_RATE_COST' value c.unit_rate_cost,
                                                                key 'RATE_CODE' value c.rate_code,
                                                                key 'NO_OF_MONTHS' value c.invoice_days,
                                                                key 'TOTAL_LINE_AMOUNT' value c.invoice_days * c.unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                (
                                                    select
                                                        c.pers_id,
                                                        e.unit_rate_cost,
                                                        c.rate_code,
                                                        c.invoice_days
                                                    from
                                                        invoice_distribution_summary c,
                                                        ar_invoice_lines             e
                                                    where
                                                            c.invoice_line_id = e.invoice_line_id
                                                        and e.invoice_id = c.invoice_id
                                        --AND e.STATUS <> 'VOID'
                                                        and e.status not in('VOID', 'CANCELLED')   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                                                        and e.invoice_id = p_invoice_id
                                                        and e.invoice_line_type = 'ACTIVE_ADJUSTMENT'
                                                        and c.invoice_kind = 'ACTIVE_ADJUSTMENT'
                                                )          c,
                                                (
                                                    select distinct
                                                        pers_id,
                                                        trunc(enrolled_date)  enrolled_date,
                                                        trunc(effective_date) effective_date,
                                                        invoice_id,
                                                        invoice_days
                                                    from
                                                        ar_invoice_dist_plans
                                                    where
                                                            invoice_kind = 'ACTIVE_ADJUSTMENT'
                                                        and invoice_id = p_invoice_id
                                                )          a,
                                                person     p,
                                                pay_reason d
                                            where
                                                    a.invoice_id = p_invoice_id
                                                and a.pers_id = c.pers_id
                                                and a.pers_id = p.pers_id
                                                and c.rate_code = to_char(d.reason_code)
                                -- AND   D.PLAN_TYPE = p_product_type   commneted by joshi for 11009  and added below statment.
                                                and d.product_type <> 'HRA'
                                        ),
                                                key 'HRA_ACTIVE_ADJUSTMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'PERS_NAME' value p.last_name
                                                                              || ','
                                                                              || p.first_name,
                                                                key 'DESCRIPTION' value d.reason_name,
                                                                key 'ENROLLED_DATE' value to_char(a.enrolled_date, 'MM/DD/YYYY'),
                                                                key 'EFFECTIVE_DATE' value to_char(a.effective_date, 'MM/DD/YYYY'),
                                                                key 'UNIT_RATE_COST' value c.unit_rate_cost,
                                                                key 'RATE_CODE' value c.rate_code,
                                                                key 'NO_OF_MONTHS' value c.invoice_days,
                                                                key 'TOTAL_LINE_AMOUNT' value c.invoice_days * c.unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                (
                                                    select
                                                        c.pers_id,
                                                        e.unit_rate_cost,
                                                        c.rate_code,
                                                        c.invoice_days
                                                    from
                                                        invoice_distribution_summary c,
                                                        ar_invoice_lines             e
                                                    where
                                                            c.invoice_line_id = e.invoice_line_id
                                                        and e.invoice_id = c.invoice_id
                                        --AND e.STATUS <> 'VOID'
                                                        and e.status not in('VOID', 'CANCELLED')   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                                                        and e.invoice_id = p_invoice_id
                                                        and e.invoice_line_type = 'ACTIVE_ADJUSTMENT'
                                                        and c.invoice_kind = 'ACTIVE_ADJUSTMENT'
                                                )          c,
                                                (
                                                    select distinct
                                                        pers_id,
                                                        trunc(enrolled_date)  enrolled_date,
                                                        trunc(effective_date) effective_date,
                                                        invoice_id,
                                                        invoice_days
                                                    from
                                                        ar_invoice_dist_plans
                                                    where
                                                            invoice_kind = 'ACTIVE_ADJUSTMENT'
                                                        and invoice_id = p_invoice_id
                                                )          a,
                                                person     p,
                                                pay_reason d
                                            where
                                                    a.invoice_id = p_invoice_id
                                                and a.pers_id = c.pers_id
                                                and a.pers_id = p.pers_id
                                                and c.rate_code = to_char(d.reason_code)
                                -- AND   D.PLAN_TYPE = p_product_type   commneted by joshi for 11009  and added below statment.
                                                and d.product_type = 'HRA'
                                        ),
                                                key 'EE_FSA_ACTIVE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pers_name,
                                                                key 'ACC_NUM' value acc_num,
                                                                key 'DESCRIPTION' value description,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(no_of_months * unit_rate_cost, 'fm9999G990D00'
                                                                                  ),
                                                                key 'TOT_C' value no_of_months * unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                invoice_detail_report_v
                                            where
                                                    invoice_id = p_invoice_id
                                                and invoice_reason = 'ACTIVE'
                                                and rate_code <> '42'
                                                and(plan_type <> 'HRA'
                                                    or plan_type is null)
                                        ),
                                                key 'EE_FSA_RUNOUT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pers_name,
                                                                key 'ACC_NUM' value acc_num,
                                                                key 'DESCRIPTION' value description,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(no_of_months * unit_rate_cost, 'fm9999G990D00'
                                                                                  ),
                                                                key 'TOT_C' value no_of_months * unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                invoice_detail_report_v
                                            where
                                                    invoice_id = p_invoice_id
                                                and invoice_reason in('RUNOUT_INVOICE_TERM', 'RUNOUT_PLAN_YEAR', 'RUNOUT')
                                                and(plan_type <> 'HRA'
                                                    or plan_type is null)
                                        ),
                                                key 'EE_FSA_NEW_ENROLLMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pers_name,
                                                                key 'ACC_NUM' value acc_num,
                                                                key 'DESCRIPTION' value description,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(no_of_months * unit_rate_cost, 'fm9999G990D00'
                                                                                  ),
                                                                key 'TOT_C' value no_of_months * unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                invoice_detail_report_v
                                            where
                                                    invoice_id = p_invoice_id
                                                and invoice_reason = 'NEW_ENROLLMENT'
                                                and(plan_type <> 'HRA'
                                                    or plan_type is null)
                                        ),
                                                key 'EE_FSA_TERMINATION' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pers_name,
                                                                key 'ACC_NUM' value acc_num,
                                                                key 'DESCRIPTION' value description,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(no_of_months * unit_rate_cost, 'fm9999G990D00'
                                                                                  ),
                                                                key 'TOT_C' value no_of_months * unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                invoice_detail_report_v
                                            where
                                                    invoice_id = p_invoice_id
                                                and invoice_reason = 'TERMINATION'
                                                and(plan_type <> 'HRA'
                                                    or plan_type is null)
                                        ),
                                                key 'EE_FSA_ACTIVE_ADJUSTMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pers_name,
                                                                key 'ACC_NUM' value acc_num,
                                                                key 'DESCRIPTION' value description,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(no_of_months * unit_rate_cost, 'fm9999G990D00'
                                                                                  ),
                                                                key 'TOT_C' value no_of_months * unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                invoice_detail_report_v
                                            where
                                                    invoice_id = p_invoice_id
                                                and invoice_reason = 'ACTIVE_ADJUSTMENT'
                                                and(plan_type <> 'HRA'
                                                    or plan_type is null)
                                        ),
                                                key 'EE_DEBIT_CARD' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pers_name,
                                                                key 'ACC_NUM' value acc_num,
                                                                key 'DESCRIPTION' value description,
                                                                key 'NO_OF_MONTHS' value no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(no_of_months * unit_rate_cost, 'fm9999G990D00'
                                                                                  ),
                                                                key 'TOT_C' value no_of_months * unit_rate_cost
                                                    returning clob)
                                                returning clob)
                                            from
                                                invoice_detail_report_v
                                            where
                                                    invoice_id = p_invoice_id
                                                and invoice_reason = 'DEBIT_CARD'
                                        )
                                    returning clob)
                                returning clob)
                            from
                                ar_invoice_v ar,
                                enterprise   c,
                                account      ac
                            where
                                    ar.invoice_id = p_invoice_id
                                and c.entrp_id = ac.entrp_id
                                and ar.entrp_id = c.entrp_id
                                and ar.invoice_reason = 'FEE'
                                and ar.status_code not in('VOID', 'CANCELLED')
                        )
                    returning clob)
                returning clob)
            into l_invoice_det
            from
                dual;

        end if;

        if length(l_invoice_det) = 0
        or l_invoice_det is null then
            select
                json_arrayagg(
                    json_object(
                        key 'data' value ''
                    )
                )
            into l_invoice_det
            from
                dual;

        end if;

        return l_invoice_det;
    end get_fee_invoice;

    function get_erisa500_invoice (
        p_invoice_id in number
    ) return clob is
        l_erisacobrapop clob;
    begin
        select
            json_arrayagg(
                json_object(
                    key 'data' value(
                        select
                            json_arrayagg(
                                json_object(
                                    key 'INVOICE_ID' value ar.invoice_id,
                                            key 'INVOICE_NUMBER' value ar.invoice_number,
                                            key 'INVOICE_TERM' value ar.invoice_term,
                                            key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                            key 'INVOICE_PERIOD' value ar.coverage_period,
                                            key 'EMPLOYER_ADDRESS' value ar.billing_name
                                                                         || chr(10)
                                                                         || 'Attn: '
                                                                         || ar.billing_attn
                                                                         || chr(10)
                                                                         || ar.billing_address
                                                                         || chr(10)
                                                                         || ar.billing_city
                                                                         || ', '
                                                                         || ar.billing_state
                                                                         || ar.billing_zip,
                                            key 'INVOICE_AMOUNT' value '$'
                                                                       || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)),
                                                                                  'fm9999G990D00'),
                                            key 'PAID_AMOUNT' value '$'
                                                                    || to_char(ar.paid_amount, 'fm9999G990D00'),
                                            key 'CUR_BAL_DUE' value '$'
                                                                    || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)) - ar.paid_amount
                                                                    ,
                                                                               'fm9999G990D00'),
                                            key 'BAL_DUE' value '$'
                                                                || to_char(
                                        nvl(
                                            pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                            ),
                                            0
                                        ),
                                        'fm9999G990D00'
                                    ),
                                            key 'TOTAL_DUE' value '$'
                                                                  || to_char(nvl(ar.pending_amount, 0) + nvl(
                                        pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                        ),
                                        0
                                    ),
                                                                             'fm9999G990D00'),
                                            key 'INVOICE_LINES_ERISA500' value(
                                        select
                                            json_arrayagg(
                                                json_object(
                                                    key 'DESCRIPTION' value al.description,
                                                            key 'FEE' value '$'
                                                                            || to_char(al.unit_rate_cost, 'fm9999G990D00'),
                                                            key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                          || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                          )
                                                returning clob)
                                            returning clob)
                                        from
                                            ar_invoice_lines al
                                        where
                                            al.invoice_id = ar.invoice_id
                                    )
                                returning clob)
                            returning clob)
                        from
                            ar_invoice_v ar,
                            enterprise   c,
                            account      ac
                        where
                                ar.invoice_id = p_invoice_id
                            and c.entrp_id = ac.entrp_id
                            and ar.entrp_id = c.entrp_id
                    )
                returning clob)
            returning clob)
        into l_erisacobrapop
        from
            dual;

        if length(l_erisacobrapop) = 0
        or l_erisacobrapop is null then
            select
                json_arrayagg(
                    json_object(
                        key 'data' value ''
                    )
                )
            into l_erisacobrapop
            from
                dual;

        end if;

        return l_erisacobrapop;
    end get_erisa500_invoice;

    procedure run_hsa_invoice (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.acc_num acc_num,
                ar.invoice_id,
                   --     json_query (PC_OFFICE_REPORTS.get_hsa_invoice(ar.invoice_id),'$.data[0]') HSA_INV,
                c.entrp_code,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value c.name,
                                key 'INVOICE_PERIOD' value to_char(ar.start_date, 'MM/DD/YYYY')
                                                           || '-'
                                                           || to_char(ar.end_date, 'MM/DD/YYYY'),
                                key 'ACC_NUM' value ar.acc_num
                    )
                place_holder
            from
                ar_invoice_v ar,
                enterprise   c,
                account      ac
            where
                    ar.invoice_id = p_invoice_id
                and ar.account_type = 'HSA'
                and ar.status_code not in ( 'VOID', 'CANCELLED' )
                and c.entrp_id = ac.entrp_id
                and ar.entrp_id = c.entrp_id
        ) loop
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            l_clob := pc_office_reports.get_hsa_invoice(i.invoice_id, 'PL/SQL');
            dbms_output.put_line(l_clob);
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
              --          p_template_source => q'[HSA_Invoice.docx]',
                    p_template_source => q'[Fee_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
               --         p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

           /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'FEE_BILLING', 'HSA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'ADMINFEEINVOICEACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_hsa_invoice;

    function get_hsa_invoice (
        p_invoice_id in number,
        p_run_mode   in varchar2 default 'APEX'
    ) return clob is
        l_hsa_invoice clob;
        v_emp_total   number;
    begin
        begin
            select
                nvl(
                    sum(al.total_line_amount),
                    0
                )
            into v_emp_total
            from
                ar_invoice_v                 ar,
                ar_invoice_lines             al,
                invoice_distribution_summary ds,
                account                      ac,
                person                       pe
            where
                    ar.invoice_id = p_invoice_id
                and ar.invoice_id = al.invoice_id
                and ar.invoice_id = ds.invoice_id
                and ds.invoice_line_id = al.invoice_line_id
                and ds.pers_id = ac.pers_id
                and ds.pers_id = pe.pers_id
                and ar.account_type = 'HSA'
                and ar.status_code not in ( 'VOID', 'CANCELLED' );

        exception
            when no_data_found then
                v_emp_total := 0;
        end;

        if p_run_mode = 'APEX' then
            select
                json_arrayagg(
                    json_object(
                        key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'INVOICE_ID' value ar.invoice_id,
                                                key 'INVOICE_NUMBER' value ar.invoice_number,
                                                key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                                key 'INVOICE_PERIOD' value ar.coverage_period,
                                                key 'EMPLOYER_ADDRESS' value ar.billing_name
                                                                             || chr(10)
                                                                             || 'Attn: '
                                                                             || ar.billing_attn
                                                                             || chr(10)
                                                                             || ar.billing_address
                                                                             || chr(10)
                                                                             || ar.billing_city
                                                                             || ', '
                                                                             || ar.billing_state
                                                                             || ar.billing_zip,
                    --PC_ENTRP.get_entrp_name(AC.ENTRP_ID)  || ' , ' || PC_ENTRP.GET_STATE(AC.ENTRP_ID)  || ',  ' ||  PC_ENTRP.GET_CITY(AC.ENTRP_ID),
                                                key 'INVOICE_AMOUNT' value '$'
                                                                           || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)),
                                                                                      'fm9999G990D00'),
                                                key 'PAID_AMOUNT' value '$'
                                                                        || to_char(ar.paid_amount, 'fm9999G990D00'),
                                                key 'PAY_RECVD' value '$'
                                                                      || to_char(ar.paid_amount, 'fm9999G990D00'),
                                                key 'CUR_BAL_DUE' value '$'
                                                                        || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)) - ar.paid_amount
                                                                        ,
                                                                                   'fm9999G990D00'),
                                                key 'BAL_DUE' value '$'
                                                                    || to_char(
                                            nvl(
                                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                                ),
                                                0
                                            ),
                                            'fm9999G990D00'
                                        ),
                                                key 'OUT_BAL' value '$'
                                                                    || to_char(
                                            nvl(
                                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                                ),
                                                0
                                            ),
                                            'fm9999G990D00'
                                        ),
                                                key 'TOTAL_DUE' value '$'
                                                                      || to_char(nvl(ar.pending_amount, 0) + nvl(
                                            pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                            ),
                                            0
                                        ),
                                                                                 'fm9999G990D00'),
                                                key 'EMP_TOTAL' value '$' || to_char(v_emp_total, 'fm9999G990D00'),
                                                key 'ENTRP_CODE' value c.entrp_code,
                                                key 'ENTRP_NAME' value c.name,
                                                key 'INVOICE_LINES_HSA' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                                key 'NO_OF_MONTHS' value al.no_of_months,
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              )
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al
                                            where
                                                al.invoice_id = p_invoice_id
                                        ),
                                                key 'PAY_CONT_HSA' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EMP_NAME' value pe.full_name,
                                                                key 'ACC_NUM' value ac.acc_num,
                                                                key 'DESCRIPTION' value al.description,
                                                                key 'NO_OF_MONTHS' value al.no_of_months,
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(al.total_line_amount, 'fm9999G990D00')
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines             al,
                                                invoice_distribution_summary ds,
                                                account                      ac,
                                                person                       pe
                                            where
                                                    ds.invoice_id = p_invoice_id
                                                and ds.invoice_line_id = al.invoice_line_id
                                                and ds.pers_id = ac.pers_id
                                                and ds.pers_id = pe.pers_id
                                        )
                                    returning clob)
                                returning clob)
                            from
                                ar_invoice_v ar,
                                enterprise   c,
                                account      ac
                            where
                                    ar.invoice_id = p_invoice_id
                                and ar.account_type = 'HSA'
                                and ar.status_code not in('VOID', 'CANCELLED')
                                and c.entrp_id = ac.entrp_id
                                and ar.entrp_id = c.entrp_id
                        )
                    returning clob)
                returning clob)
            into l_hsa_invoice
            from
                dual;

        else
            select
                json_arrayagg(
                    json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'INVOICE_NUMBER' value ar.invoice_number,
                                key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                key 'INVOICE_PERIOD' value ar.coverage_period,
                                key 'EMPLOYER_ADDRESS' value ar.billing_name
                                                             || chr(10)
                                                             || 'Attn: '
                                                             || ar.billing_attn
                                                             || chr(10)
                                                             || ar.billing_address
                                                             || chr(10)
                                                             || ar.billing_city
                                                             || ', '
                                                             || ar.billing_state
                                                             || ar.billing_zip,
                        --PC_ENTRP.get_entrp_name(AC.ENTRP_ID)  || ' , ' || PC_ENTRP.GET_STATE(AC.ENTRP_ID)  || ',  ' ||  PC_ENTRP.GET_CITY(AC.ENTRP_ID),
                                key 'INVOICE_AMOUNT' value '$'
                                                           || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)),
                                                                      'fm9999G990D00'),
                                key 'PAID_AMOUNT' value '$'
                                                        || to_char(ar.paid_amount, 'fm9999G990D00'),
                                key 'PAY_RECVD' value '$'
                                                      || to_char(ar.paid_amount, 'fm9999G990D00'),
                                key 'CUR_BAL_DUE' value '$'
                                                        || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)) - ar.paid_amount,
                                                                   'fm9999G990D00'),
                                key 'BAL_DUE' value '$'
                                                    || to_char(
                            nvl(
                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id),
                                0
                            ),
                            'fm9999G990D00'
                        ),
                                key 'OUT_BAL' value '$'
                                                    || to_char(
                            nvl(
                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id),
                                0
                            ),
                            'fm9999G990D00'
                        ),
                                key 'TOTAL_DUE' value '$'
                                                      || to_char(nvl(ar.pending_amount, 0) + nvl(
                            pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id),
                            0
                        ),
                                                                 'fm9999G990D00'),
                                key 'EMP_TOTAL' value '$' || to_char(v_emp_total, 'fm9999G990D00'),
                                key 'ENTRP_CODE' value c.entrp_code,
                                key 'ENTRP_NAME' value c.name,
                                key 'INVOICE_LINES' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'DESCRIPTION' value al.description,
                                                key 'NO_OF_SUBSCRIBERS' value al.quantity,
                                                key 'NO_OF_MONTHS' value al.no_of_months,
                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                              || to_char(al.total_line_amount, 'fm9999G990D00')
                                    returning clob)
                                returning clob)
                            from
                                ar_invoice_lines al
                            where
                                al.invoice_id = p_invoice_id
                        ),
                                key 'PAY_CONT' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'EMP_NAME' value pe.full_name,
                                                key 'ACC_NUM' value ac.acc_num,
                                                key 'DESCRIPTION' value al.description,
                                                key 'NO_OF_MONTHS' value al.no_of_months,
                                                key 'TOTAL' value '$'
                                                                  || to_char(al.total_line_amount, 'fm9999G990D00')
                                    returning clob)
                                returning clob)
                            from
                                ar_invoice_lines             al,
                                invoice_distribution_summary ds,
                                account                      ac,
                                person                       pe
                            where
                                    ds.invoice_id = p_invoice_id
                                and ds.invoice_line_id = al.invoice_line_id
                                and ds.pers_id = ac.pers_id
                                and ds.pers_id = pe.pers_id
                        )
                    returning clob)
                returning clob)
            into l_hsa_invoice
            from
                ar_invoice_v ar,
                enterprise   c,
                account      ac
            where
                    ar.invoice_id = p_invoice_id
                and ar.account_type = 'HSA'
                and ar.status_code not in ( 'VOID', 'CANCELLED' )
                and c.entrp_id = ac.entrp_id
                and ar.entrp_id = c.entrp_id;

        end if;

        if length(l_hsa_invoice) = 0
        or l_hsa_invoice is null then
            select
                json_arrayagg(
                    json_object(
                        key 'data' value ''
                    )
                )
            into l_hsa_invoice
            from
                dual;

        end if;

        return l_hsa_invoice;
    exception
        when others then
            raise;
    end get_hsa_invoice;

    procedure run_funding_invoice (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email          varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
    begin
        aop_api_pkg.g_output_merge := 'true';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_sqlerrm := '';
        for i in (
            select
                ar.acc_num                         acc_num,
                ar.invoice_id,
                json_query(pc_office_reports.get_funding_invoice(ar.invoice_id),
                           '$.data[0]')            fund_inv,
                json_value(pc_office_reports.get_funding_invoice(ar.invoice_id),
                           '$.data[0].ENTRP_CODE') entrp_code,
                json_value(pc_office_reports.get_funding_invoice(ar.invoice_id),
                           '$.filename')           filename,
                json_object(
                        key 'INVOICE_ID' value ar.invoice_id,
                                key 'ENTRP_NAME' value json_value(pc_office_reports.get_funding_invoice(ar.invoice_id),
           '$.data[0].ENTRP_NAME'),
                                key 'INVOICE_DATE' value json_value(pc_office_reports.get_funding_invoice(ar.invoice_id),
           '$.data[0].INVOICE_DATE'),
                                key 'PLAN_TYPE' value json_value(pc_office_reports.get_funding_invoice(ar.invoice_id),
           '$.data[0].PLAN_TYPE'),
                                key 'ACC_NUM' value ar.acc_num
                    )
                place_holder
            from
                ar_invoice_v ar,
                enterprise   c,
                account      ac
            where
                    ar.invoice_id = nvl(p_invoice_id, invoice_id)
                and c.entrp_id = ac.entrp_id
                and ar.entrp_id = c.entrp_id
                and ar.invoice_reason = 'FUNDING'
                and ar.status_code not in ( 'VOID', 'CANCELLED' )
        ) loop
            dbms_output.put_line(i.fund_inv);
            l_acc_num := i.acc_num;
            aop_api_pkg.g_output_filename := i.acc_num
                                             || '-'
                                             || i.invoice_id;
            begin
                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => i.fund_inv,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Funding_Invoice.docx]',
                    p_output_type     => 'pdf',
                    p_output_merge    => 'true',
                    p_output_filename => aop_api_pkg.g_output_filename,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
              --          p_output_to       => CASE WHEN p_output = 'FTP'  THEN 'CLOUD' ELSE 'BROWSER' END,
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;

           /* default email IT-Team@sterlingadministration.com */
            l_to_email := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email)
                into l_to_email
                from
                    table ( pc_contact.get_notify_emails(i.entrp_code, 'FUND_BILLING', 'HRAFSA', i.invoice_id) );

            exception
                when no_data_found then
                    l_to_email := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email is null then
                l_to_email := 'IT-team@sterlingadministration.com';
            end if;
            l_place_holders := i.place_holder;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'FUNDINGINVOICEACHEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            -- Attach BLOB file to the email
            apex_mail.add_attachment(
                p_mail_id    => l_mail_id,
                p_attachment => l_return,
                p_filename   => aop_api_pkg.g_output_filename,
                p_mime_type  => l_mime_type
            );

        end loop;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: '
                                 || to_char(sqlcode)
                                 || sqlerrm);
    end run_funding_invoice;

    procedure get_fsafinalcomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email_list     varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
        l_date              varchar2(255);
    begin
        aop_api_pkg.g_output_merge := 'true'; 

   --     if p_output = 'FTP' THEN
        aop_api_pkg.g_cloud_provider := 'sftp';
        aop_api_pkg.g_cloud_location := '/home/ftp_admin';
        aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
        ;

   --     END IF;

        l_sqlerrm := '';
        for rec in (
            select
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                b.acc_num                           acc_num,
                b.acc_id                            acc_id,
                b.entrp_id                          entrp_id,
                to_char(
                    max(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   as plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   as plan_end,
                a.plan_docs,
                l.description                       as ndt_preference
            from
                     ben_plan_enrollment_setup a
                join account            b on a.entrp_id = b.entrp_id
                join account_preference c on b.acc_id = c.acc_id
                join lookups            l on c.ndt_preference = l.lookup_code
            where
                ( p_account is null
                  or b.acc_num = p_account )
                and c.ndt_preference = 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and trunc(a.plan_end_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.status = 'A'
                and plan_type in ( 'FSA', 'LPF', 'DCA' )
                and b.end_date is null
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and not exists (
                    select
                        1
                    from
                        plan_notices pn
                    where
                            pn.notice_type = 'LAST_QTR_NDT'
                        and pn.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and pn.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                b.acc_id,
                b.entrp_id,
                a.plan_docs,
                l.description
        ) loop
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );

            /* default email IT-Team@sterlingadministration.com */
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list)
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(rec.entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value rec.plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'FSAFINALCOMPNDTREQUESTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            pc_benefit_plans.insert_plan_notice(rec.entrp_id, 'FSA', 'LAST_QTR_NDT', 0);
        end loop;

    end get_fsafinalcomprehensivendtreport;

    procedure get_hrafinalcomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_acc_num       varchar2(255);
        l_plan_start    varchar2(255);
        l_plan_end      varchar2(255);
        l_entrp_id      number;
        l_date          varchar2(255);
        l_to_email_list varchar2(4000);
        l_subject       varchar2(4000);
        l_body_html     clob;
        l_body_text     clob;
        l_place_holders clob;
        l_clob          clob;
        l_mail_id       number;
        l_sqlerrm       varchar2(32000);
    begin
        for rec in (
            select
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                b.acc_num,
                b.acc_id,
                b.entrp_id,
                to_char(
                    max(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   as plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   as plan_end,
                a.plan_docs,
                l.description                       as ndt_preference
            from
                ben_plan_enrollment_setup a,
                account                   b,
                account_preference        c,
                lookups                   l
            where
                trunc(a.plan_end_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and b.end_date is null
                and a.product_type = 'HRA'
                and a.status = 'A'
                and nvl(c.ndt_preference, '-1') = 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and c.ndt_preference = l.lookup_code
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and not exists (
                    select
                        1
                    from
                        plan_notices c
                    where
                            c.notice_type = 'LAST_QTR_NDT'
                        and c.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
                and ( p_account is null
                      or b.acc_num = p_account )
            group by
                b.acc_num,
                b.acc_id,
                b.entrp_id,
                a.plan_docs,
                l.description
        ) loop
            l_acc_num := rec.acc_num;
            l_entrp_id := rec.entrp_id;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );

        /* default email IT-Team@sterlingadministration.com */
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list, ',')
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;
            apex_mail.prepare_template(
                p_static_id      => 'HRAFINALCOMPNDTREQUESTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'HRA', 'LAST_QTR_NDT', 0);
        end loop;
    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('Error: ' || l_sqlerrm);
    end get_hrafinalcomprehensivendtreport;

    procedure get_hrafinalndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_acc_num        varchar2(255);
        l_to_email_list  varchar2(255);
        l_subject        varchar2(4000);
        l_body_html      clob;
        l_body_text      clob;
        l_place_holders  clob;
        l_mail_id        number;
        l_date           varchar2(255);
        l_plan_start     varchar2(255);
        l_plan_end       varchar2(255);
        l_entrp_id       number;
        l_employer_name  varchar2(4000);
        l_ndt_preference varchar2(255);
        l_clob           clob;
    begin
        dbms_output.put_line('Start HRAFinalNDTReport:');
        for rec in (
            select
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                b.acc_num                           as acc_num,
                b.acc_id,
                b.entrp_id,
                to_char(
                    min(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   as plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   as plan_end,
                a.plan_docs,
                l.description                       as ndt_preference
            from
                     ben_plan_enrollment_setup a
                join account            b on a.entrp_id = b.entrp_id
                join account_preference c on b.acc_id = c.acc_id
                join lookups            l on c.ndt_preference = l.lookup_code
            where
                trunc(a.plan_end_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and ( p_account is null
                      or b.acc_num = p_account )
                and b.end_date is null
                and a.product_type = 'HRA'
                and a.status = 'A'
                and nvl(c.ndt_preference, '-1') <> 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and not exists (
                    select
                        1
                    from
                        plan_notices c
                    where
                            c.notice_type = 'LAST_QTR_NDT'
                        and c.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                b.acc_id,
                b.entrp_id,
                a.plan_docs,
                l.description
        ) loop
            l_acc_num := rec.acc_num;
            l_entrp_id := rec.entrp_id;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_employer_name := rec.employer_name;
            l_ndt_preference := rec.ndt_preference;
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );

        /* default email IT-Team@sterlingadministration.com */
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list, ',')
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;

        -- Generate JSON placeholders
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;

        -- Prepare email content using template
            apex_mail.prepare_template(
                p_static_id      => 'HRAPYENDTREQUESTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

        -- Send the email
            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'HRA', 'LAST_QTR_NDT', 0);
        end loop;

    end get_hrafinalndtreport;

    procedure get_hrapopfinalndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_sqlerrm       varchar2(32000);
        l_clob          clob;
        l_place_holders clob;
        l_mail_id       number;
        l_subject       varchar2(4000);
        l_body_html     clob;
        l_body_text     clob;
        l_to_email_list varchar2(255);
        l_date          varchar2(255);
        l_plan_start    varchar2(255);
        l_plan_end      varchar2(255);
        l_acc_num       varchar2(255);
        l_entrp_id      number;
    begin
        dbms_output.put_line('Begin POP NDT Report Processing...');
        for rec in (
            select
                b.acc_num,
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                to_char(
                    min(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   plan_end,
                b.entrp_id
            from
                ben_plan_enrollment_setup a,
                account                   b,
                account_preference        c,
                lookups                   l
            where
                trunc(a.plan_end_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and ( p_account is null
                      or b.acc_num = p_account )
                and b.account_type = 'POP'
                and a.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and a.status = 'A'
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and a.plan_type in ( 'COMP_POP', 'COMP_POP_RENEW', 'NDT' )
                and b.end_date is null
                and not exists (
                    select
                        1
                    from
                        plan_notices c
                    where
                            notice_type = 'LAST_QTR_NDT'
                        and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                pc_entrp.get_entrp_name(b.entrp_id),
                b.entrp_id
        ) loop
            l_acc_num := rec.acc_num;
            l_entrp_id := rec.entrp_id;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );
            dbms_output.put_line('l_acc_num :' || l_acc_num);
            dbms_output.put_line('l_entrp_id :' || l_entrp_id);
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list, ',')
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;
            apex_mail.prepare_template(
                p_static_id      => 'POPNDTREQUESTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

        -- Send the email
            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'NDT', 'LAST_QTR_NDT', 0);
        end loop;

        dbms_output.put_line('POP NDT Report Completed.');
    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('Error: ' || l_sqlerrm);
    end get_hrapopfinalndtreport;

    procedure get_fsaprelimndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_clob           clob;
        l_mail_id        number;
        l_subject        varchar2(4000);
        l_body_html      clob;
        l_body_text      clob;
        l_place_holders  clob;
        l_acc_num        varchar2(255);
        l_plan_start     varchar2(255);
        l_plan_end       varchar2(255);
        l_to_email_list  varchar2(255);
        l_employer_name  varchar2(4000);
        l_ndt_preference varchar2(255);
        l_template_name  varchar2(255);
        l_entrp_id       number;
        l_date           varchar2(255);
    begin
        dbms_output.put_line('Start FSA Prelim NDT Report');
        for rec in (
            select
                b.acc_num,
                to_char(
                    max(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   as plan_start_dt,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   as plan_end_dt,
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                b.entrp_id,
                a.plan_docs,
                c.ndt_preference
            from
                ben_plan_enrollment_setup a,
                account                   b,
                account_preference        c,
                lookups                   l
            where
                trunc(a.plan_start_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.plan_end_date > sysdate
                and a.status = 'A'
                and a.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and a.plan_type in ( 'FSA', 'DCA', 'LPF' )
                and b.end_date is null
                and nvl(c.ndt_preference, '-1') <> 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and ( p_account is null
                      or b.acc_num = p_account )
                and not exists (
                    select
                        1
                    from
                        plan_notices c
                    where
                            c.notice_type = '1ST_QTR_NDT'
                        and c.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                pc_entrp.get_entrp_name(b.entrp_id),
                a.plan_docs,
                c.ndt_preference,
                b.entrp_id
        ) loop
            l_acc_num := rec.acc_num;
            l_plan_start := rec.plan_start_dt;
            l_plan_end := rec.plan_end_dt;
            l_employer_name := rec.employer_name;
            l_entrp_id := rec.entrp_id;
            l_ndt_preference := rec.ndt_preference;
            dbms_output.put_line('l_acc_num ' || l_acc_num);
            dbms_output.put_line('l_entrp_id ' || l_entrp_id);
            dbms_output.put_line('l_plan_start ' || l_plan_start);
            dbms_output.put_line('l_plan_end ' || l_plan_end);
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list)
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;

        -- Create JSON for placeholders
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_START_DT' value l_plan_start,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;
            if l_ndt_preference = 'BASIC(BPS)' then
                l_template_name := 'FSAPRELIMNDTHCDCREQUESTEMAIL';
            else
                l_template_name := 'FSAPRELIMNDTREQUESTEMAIL';
            end if;

            apex_mail.prepare_template(
                p_static_id      => l_template_name,
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'FSA', '1ST_QTR_NDT', 0);
        end loop;

    end get_fsaprelimndtreport;

    procedure get_hracomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_clob          clob;
        l_return        blob;
        l_file_name     varchar2(255);
        l_file_id       number;
        l_sqlerrm       varchar2(32000);
        l_mail_id       number;
        l_place_holders clob;
        l_mime_type     varchar2(100) := 'application/pdf';
        l_acc_num       varchar2(255);
        l_to_email_list varchar2(255);
        l_subject       varchar2(4000);
        l_body_html     clob;
        l_body_text     clob;
        l_date          varchar2(255);
        l_plan_start    varchar2(255);
        l_plan_end      varchar2(255);
        l_entrp_id      number;
    begin
        aop_api_pkg.g_output_merge := 'true';
        aop_api_pkg.g_cloud_provider := 'sftp';
        aop_api_pkg.g_cloud_location := '/home/ftp_admin';
        aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
        ;
        for rec in (
            select
                b.acc_num,
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                to_char(
                    min(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   plan_end,
                a.plan_docs,
                c.ndt_preference,
                b.entrp_id
            from
                ben_plan_enrollment_setup a,
                account                   b,
                account_preference        c,
                lookups                   l
            where
                trunc(a.plan_start_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.plan_end_date > sysdate
                and a.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and a.status = 'A'
                and a.product_type = 'HRA'
                and b.end_date is null
                and c.ndt_preference = 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and not exists (
                    select
                        1
                    from
                        plan_notices pn
                    where
                            pn.notice_type = '1ST_QTR_NDT'
                        and pn.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and pn.entity_id = a.ben_plan_id
                )
                and ( p_account is null
                      or b.acc_num = p_account )
            group by
                b.acc_num,
                pc_entrp.get_entrp_name(b.entrp_id),
                a.plan_docs,
                c.ndt_preference,
                b.entrp_id
        ) loop
            l_acc_num := rec.acc_num;
            l_entrp_id := rec.entrp_id;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list)
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;
            apex_mail.prepare_template(
                p_static_id      => 'HRACOMPREHENSIVENDTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'HRA', '1ST_QTR_NDT', 0);
        end loop;

    end get_hracomprehensivendtreport;

    procedure get_fsafinalndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email_list     varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
        l_date              varchar2(255);
        l_employer_name     varchar2(4000);
        l_entrp_id          number;
        l_plan_start        varchar2(255);
        l_plan_end          varchar2(255);
        l_ndt_preference    varchar2(255);
        l_template_year     varchar2(4);
        l_exceldoc          varchar2(4000);
        l_template_name     varchar2(4000);
    begin
        aop_api_pkg.g_output_merge := 'true'; 

   --     if p_output = 'FTP' THEN
        aop_api_pkg.g_cloud_provider := 'sftp';
        aop_api_pkg.g_cloud_location := '/home/ftp_admin';
        aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
        ;

   --     END IF;

        l_sqlerrm := '';
        for rec in (
            select
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                b.acc_num                           acc_num,
                b.acc_id                            acc_id,
                b.entrp_id                          entrp_id,
                to_char(
                    max(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   as plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   as plan_end,
                a.plan_docs,
                l.description                       as ndt_preference
            from
                     ben_plan_enrollment_setup a
                join account            b on a.entrp_id = b.entrp_id
                join account_preference c on b.acc_id = c.acc_id
                join lookups            l on c.ndt_preference = l.lookup_code
            where
                ( p_account is null
                  or b.acc_num = p_account )
                and c.ndt_preference = 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and trunc(a.plan_end_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.status = 'A'
                and plan_type in ( 'FSA', 'LPF', 'DCA' )
                and b.end_date is null
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and not exists (
                    select
                        1
                    from
                        plan_notices pn
                    where
                            pn.notice_type = 'LAST_QTR_NDT'
                        and pn.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and pn.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                b.acc_id,
                b.entrp_id,
                a.plan_docs,
                l.description
        ) loop
            l_acc_num := rec.acc_num;
            l_employer_name := rec.employer_name;
            l_entrp_id := rec.entrp_id;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_ndt_preference := rec.ndt_preference;
            if length(l_plan_start) >= 10 then
                l_template_year := substr(l_plan_start, 7, 4);
            else
                l_template_year := to_char(sysdate, 'YYYY');
            end if;

            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list)
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;
            if l_ndt_preference = 'BASIC(BPS)' then
                l_template_name := 'FSAPYENDTHCDCREQUESTEMAIL';
            else
                l_template_name := 'FSAPYENDTREQUESTEMAIL';
            end if;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => l_template_name,
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'FSA', 'LAST_QTR_NDT', 0);
        end loop;

    end get_fsafinalndtreport;

    procedure get_fsaprelimcomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_clob           clob;
        l_place_holders  clob;
        l_body_html      clob;
        l_body_text      clob;
        l_subject        varchar2(4000);
        l_to_email_list  varchar2(255);
        l_date           varchar2(50);
        l_plan_start     varchar2(50);
        l_plan_end       varchar2(50);
        l_entrp_id       number;
        l_acc_num        varchar2(255);
        l_mail_id        number;
        l_ndt_preference varchar2(255);
    begin
        for rec in (
            select
                b.acc_num,
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                to_char(
                    min(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   as plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   as plan_end,
                a.plan_docs,
                b.entrp_id,
                c.ndt_preference
            from
                     ben_plan_enrollment_setup a
                join account            b on a.entrp_id = b.entrp_id
                join account_preference c on b.acc_id = c.acc_id
                join lookups            l on 1 = 1
            where
                trunc(a.plan_start_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.plan_end_date > sysdate
                and a.status = 'A'
                and b.end_date is null
                and a.product_type in ( 'FSA', 'DCA', 'LPF' )
                and c.ndt_preference = 'COMPREHENSIVE'
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and ( p_account is null
                      or b.acc_num = p_account )
                and not exists (
                    select
                        1
                    from
                        plan_notices c
                    where
                            c.notice_type = '1ST_QTR_NDT'
                        and c.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                b.entrp_id,
                a.plan_docs,
                c.ndt_preference
        ) loop
            l_acc_num := rec.acc_num;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_entrp_id := rec.entrp_id;
            l_ndt_preference := rec.ndt_preference;
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );

        -- Default email
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list, ',')
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_place_holders
            from
                dual;

            apex_mail.prepare_template(
                p_static_id      => 'FSAPRELIMCOMPNDTREQUESTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'FSA', '1ST_QTR_NDT', 0);
        end loop;
    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
    end get_fsaprelimcomprehensivendtreport;

    procedure get_hraprelimndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    ) is

        l_clob              clob;
        l_return            blob;
        l_file_name         varchar2(255);
        l_file_id           number;
        l_sqlerrm           varchar2(32000);
        l_mail_id           number;
        l_place_holders     clob;
        l_mime_type         varchar2(100) := 'application/pdf'; -- Change based on file type

        l_acc_num           varchar2(255);
        l_to_email_list     varchar2(255);
        l_subject           varchar2(4000);
        l_body_html         clob;
        l_body_text         clob;
        l_table_placeholder clob;
        l_date              varchar2(255);
        l_employer_name     varchar2(4000);
        l_entrp_id          number;
        l_plan_start        varchar2(255);
        l_plan_end          varchar2(255);
        l_ndt_preference    varchar2(255);
        l_template_year     varchar2(4);
        l_exceldoc          varchar2(4000);
        l_template_name     varchar2(4000);
    begin
        aop_api_pkg.g_output_merge := 'true'; 

   --     if p_output = 'FTP' THEN
        aop_api_pkg.g_cloud_provider := 'sftp';
        aop_api_pkg.g_cloud_location := '/home/ftp_admin';
        aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
        ;

   --     END IF;

        l_sqlerrm := '';
        for rec in (
            select
                pc_entrp.get_entrp_name(b.entrp_id) as employer_name,
                b.acc_num                           acc_num,
                b.acc_id                            acc_id,
                b.entrp_id                          entrp_id,
                to_char(
                    min(a.plan_start_date),
                    'MM/DD/YYYY'
                )                                   plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   plan_end,
                a.plan_docs,
                l.description                       as ndt_preference
            from
                ben_plan_enrollment_setup a,
                account                   b,
                account_preference        c,
                lookups                   l
            where
                ( p_account is null
                  or b.acc_num = p_account )
                and c.ndt_preference <> 'COMPREHENSIVE'
                and l.lookup_name <> 'FSA_HRA_MAINT_FEE'
                and trunc(a.plan_start_date) between p_from_date and p_to_date
                and a.plan_start_date <= sysdate
                and a.plan_end_date > sysdate
                and a.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and a.product_type = 'HRA'
                and b.end_date is null
                and a.status = 'A'
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and nvl(a.plan_docs, 'N') <> 'Y'
                and not exists (
                    select
                        1
                    from
                        plan_notices c
                    where
                            notice_type = '1ST_QTR_NDT'
                        and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                b.acc_id,
                b.entrp_id,
                a.plan_docs,
                l.description
        ) loop
            l_acc_num := rec.acc_num;
            l_entrp_id := rec.entrp_id;
            l_plan_start := rec.plan_start;
            l_plan_end := rec.plan_end;
            l_date := to_char(
                add_working_days(15, sysdate),
                'MM/DD/YYYY'
            );
            l_to_email_list := 'IT-team@sterlingadministration.com';
            begin
                select
                    listagg(email_list)
                into l_to_email_list
                from
                    table ( pc_compliance.get_contact_list(l_entrp_id) );

            exception
                when no_data_found then
                    l_to_email_list := 'IT-team@sterlingadministration.com';
            end;

            if l_to_email_list is null then
                l_to_email_list := 'IT-team@sterlingadministration.com';
            end if;
            select
                json_object(
                    key 'DEADLINE_DT' value l_date,
                    key 'PLAN_END_DT' value l_plan_end
                returning clob)
            into l_clob
            from
                dual;

            l_place_holders := l_clob;

            -- Set email body content
            apex_mail.prepare_template(
                p_static_id      => 'HRAPRELIMNDTREQUESTEMAIL',
                p_placeholders   => l_place_holders,
                p_application_id => 203,
                p_subject        => l_subject,
                p_html           => l_body_html,
                p_text           => l_body_text
            );

            -- Send email 
            l_mail_id := apex_mail.send(
                p_to        => l_to_email_list,
                p_from      => 'invoice@sterlingadministration.com',
                p_subj      => l_subject,
                p_body      => l_body_html,
                p_body_html => l_body_html  -- Supports HTML formatting
            );

            pc_benefit_plans.insert_plan_notice(l_entrp_id, 'HRA', '1ST_QTR_NDT', 0);
        end loop;

    end get_hraprelimndtreport;

    function get_funding_invoice (
        p_invoice_id in number
    ) return clob is
        l_funding_invoice clob;
        v_pay_cont_total  number;
        v_cnt             number;
    begin
        select
            count(1)
        into v_cnt
        from
            ar_invoice_v
        where
                invoice_id = p_invoice_id
            and invoice_reason = 'FUNDING';

        if v_cnt > 0 then
            select
                sum(ds.rate_amount)
            into v_pay_cont_total
            from
                ar_invoice_v                 ar,
                ar_invoice_lines             al,
                invoice_distribution_summary ds,
                account                      ac,
                person                       pe
            where
                    ar.invoice_id = p_invoice_id
                and ar.invoice_id = al.invoice_id
                and ar.invoice_id = ds.invoice_id
                and ds.invoice_line_id = al.invoice_line_id
                and ds.pers_id = ac.pers_id
                and ds.pers_id = pe.pers_id
                and ar.invoice_reason = 'FUNDING'
                and ar.status_code not in ( 'VOID', 'CANCELLED' );

            select
                json_arrayagg(
                    json_object(
                        key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'INVOICE_ID' value ar.invoice_id,
                                                key 'INVOICE_NUMBER' value ar.invoice_number,
                                                key 'INVOICE_DATE' value to_char(ar.invoice_date, 'MM/DD/YYYY'),
                                                key 'EMPLOYER_ADDRESS' value ar.billing_name
                                                                             || chr(10)
                                                                             || 'Attn: '
                                                                             || ar.billing_attn
                                                                             || chr(10)
                                                                             || ar.billing_address
                                                                             || chr(10)
                                                                             || ar.billing_city
                                                                             || ', '
                                                                             || ar.billing_state
                                                                             || ar.billing_zip,
                                                key 'INVOICE_AMOUNT' value '$'
                                                                           || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)),
                                                                                      'fm9999G990D00'),
                                                key 'PAID_AMOUNT' value '$'
                                                                        || to_char(ar.paid_amount, 'fm9999G990D00'),
                                                key 'CUR_BAL_DUE' value '$'
                                                                        || to_char((ar.invoice_amount - nvl(ar.void_amount, 0)) - ar.paid_amount
                                                                        ,
                                                                                   'fm9999G990D00'),
                                                key 'BAL_DUE' value '$'
                                                                    || to_char(
                                            nvl(
                                                pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                                ),
                                                0
                                            ),
                                            'fm9999G990D00'
                                        ),
                                                key 'TOTAL_DUE' value '$'
                                                                      || to_char(nvl(ar.pending_amount, 0) + nvl(
                                            pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id
                                            ),
                                            0
                                        ),
                                                                                 'fm9999G990D00'),
                                                key 'COMMENTS' value
                                            case
                                                when ar.plan_type in('HRA', 'FSA', 'HRAFSA')
                                                     and ar.invoice_reason = 'FEE' then
                                                    'Note: Sterling''s FSA and HRA Monthly Administrative Fee Minimum is $125'
                                                else
                                                    ar.comments
                                            end,
                                                key 'PAYMENT_MSG' value ar.comments,
                                                key 'ACCOUNT_NUMBER' value ar.acc_num,
                                                key 'PAY_CONT_TOTAL' value '$'
                                                                           || to_char(
                                            nvl(v_pay_cont_total, 0),
                                            'fm9999G990D00'
                                        ),
                                                key 'ENTRP_NAME' value c.name,
                                                key 'PLAN_TYPE' value plan_type,
                                                key 'ENTRP_CODE' value c.entrp_code,
                                                key 'INVOICE_LINES_FUND' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DESCRIPTION' value al.description,
                                                                key 'FEE' value '$'
                                                                                || to_char(al.unit_rate_cost, 'fm9999G990D00'),
                                                                key 'TOTAL_LINE_AMOUNT' value '$'
                                                                                              || to_char(al.total_line_amount, 'fm9999G990D00'
                                                                                              )
                                                    returning clob)
                                                returning clob)
                                            from
                                                ar_invoice_lines al
                                            where
                                                al.invoice_id = p_invoice_id
                                        ),
                                                key 'PAY_CONT_FUND' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'ACC_NUM' value ac.acc_num,
                                                                key 'EMP_NAME' value pe.last_name
                                                                                     || ','
                                                                                     || pe.first_name,
                                                                key 'DIVISION_NAME' value pc_person.get_division_name(pe.pers_id),
                                                                key 'PLAN' value decode(ds.account_type,
                                                                                        'HSA',
                                                                                        pc_plan.plan_name(plans),
                                                                                        'LSA',
                                                                                        pc_plan.plan_name(plans),
                                                                                        plans),
                                                                key 'TOTAL' value '$'
                                                                                  || to_char(ds.rate_amount, 'fm9999G990D00')
                                                    returning clob)
                                                order by
                                                    pe.last_name
                                                returning clob)
                                            from
                                                ar_invoice_lines             al,
                                                invoice_distribution_summary ds,
                                                account                      ac,
                                                person                       pe
                                            where
                                                    ds.invoice_id = p_invoice_id
                                                and ds.invoice_line_id = al.invoice_line_id
                                                and ds.pers_id = ac.pers_id
                                                and ds.pers_id = pe.pers_id
                                        )
                                    returning clob)
                                returning clob)
                            from
                                ar_invoice_v ar,
                                enterprise   c,
                                account      ac
                            where
                                    ar.invoice_id = p_invoice_id
                                and c.entrp_id = ac.entrp_id
                                and ar.entrp_id = c.entrp_id
                                and ar.invoice_reason = 'FUNDING'
                                and ar.status_code not in('VOID', 'CANCELLED')
                        )
                    returning clob)
                returning clob)
            into l_funding_invoice
            from
                dual;

        end if;

        if length(l_funding_invoice) = 0
        or l_funding_invoice is null then
            select
                json_arrayagg(
                    json_object(
                        key 'data' value ''
                    )
                )
            into l_funding_invoice
            from
                dual;

        end if;

        return l_funding_invoice;
    end get_funding_invoice;

    procedure wl_hsa_ee is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                subscriber_welcome_letter
            where
                    trunc(start_date) <= trunc(sysdate)
                and confirmation_date is null
                and plan_code not in ( 3, 103, 203, 303, 403,
                                       507, 503, 603 )
                and pc_account.acc_balance(acc_id) > 0
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115",
                                                "port": 22,
                                                "user": "ftp_admin",
                                                "password": "5rd$eSzAw3yHn"}';
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'HSA_EE_' || l_file_id;
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'TODAY' value to_char(sysdate, 'MM/DD/YYYY'),
                                'EE_NAME' value i.person_name,
                                'EE_ADDRESS' value i.address,
                                'CITY' value i.city,
                                'ACC_NUM' value i.account_number,
                                'PR_IND_CONT' value i.initial_contrib,
                                'MONTH_SETUP' value i.month_setup,
                                'EMPLOYER' value i.employer,
                                'SINGLE_CONTRIB' value i.single_contrib,
                                'PR_FAM_CONT' value i.family_contrib,
                                'PR_YEAR' value to_char(sysdate, 'YYYY'),
                                'LAT_YEAR' value to_char(to_number(to_char(sysdate, 'YYYY')) + 1)
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[HSA_EE.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.account_number
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_hsa_ee;

    procedure wl_hsa_ee_welcome (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        l_file_name := 'HSA_EE_Welcome_Letter.pdf';
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115","port": 22,"user": "ftp_admin","password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'TODAY' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'EE_NAME' value person_name,
                                                key 'EE_ADDRESS' value nvl(address, ' '),
                                                key 'CITY' value nvl(city, ' '),
                                                key 'ACC_NUM' value account_number,
                                                key 'PR_IND_CONT' value initial_contrib,
                                                key 'MONTH_SETUP' value month_setup,
                                                key 'EMPLOYER' value employer,
                                                key 'SINGLE_CONTRIB' value single_contrib,
                                                key 'PR_FAM_CONT' value family_contrib,
                                                key 'PR_YEAR' value to_char(sysdate, 'YYYY'),
                                                key 'LAT_YEAR' value to_char(to_number(to_char(sysdate, 'YYYY')) + 1)
                                    returning clob)
                                returning clob)
                            from
                                subscriber_welcome_letter
                            where
                                    trunc(start_date) <= trunc(sysdate)
                                and confirmation_date is null
                                and plan_code not in(3, 103, 203, 303, 403,
                                                     507, 503, 603)
                                and pc_account.acc_balance(acc_id) > 0
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;

        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[HSA_EE.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
 --       mail_utility.send_email('webservice@sterlingadministration.com','vanitha.subramanyam@sterlingadministration.com',
--                                'Error in Creating HSA Employee Welcome Letter', l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_hsa_ee_welcome;

    procedure wl_hsa_er is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                employer_welcome_letter
            where
                rownum < 10
				-- where trunc(start_date) = TRUNC(sysdate) and ACCOUNT_NUMBER IS NOT NULL and confirmation_date is null
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'HSA_EE_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RN' value rownum,
                                'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'er_contact' value i.er_contact,
                                'er_name' value i.er_name,
                                'er_address' value i.address,
                                'er_city_state' value i.city,
                                'acc_num' value i.account_number
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[HSA_ER.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.account_number
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_hsa_er;

    procedure wl_hsa_er_welcome (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'HSA_ER_Welcome_Letter.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'RN' value rownum,
                                                key 'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'er_contact' value er_contact,
                                                key 'er_name' value er_name,
                                                key 'er_address' value address,
                                                key 'er_city_state' value city,
                                                key 'acc_num' value account_number
                                    returning clob)
                                returning clob)
                            from
                                employer_welcome_letter
                            where
                                rownum < 10
                        )
                                                   -- where trunc(start_date) = TRUNC(sysdate) and ACCOUNT_NUMBER IS NOT NULL and confirmation_date is null
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;

        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[HSA_ER.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating HSA Employer Welcome Letter'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_hsa_er_welcome;

    procedure wl_fsa_ee is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                today,
                person_name,
                address,
                city,
                account_number,
                employer,
                to_char(sysdate, 'YYYY') year,
                account_type,
                lang_perf,
                template_name
            from
                subscriber_hra_welcome_letter
            where
                    trunc(reg_date) <= trunc(sysdate)
                and confirmation_date is null
                and account_type = 'FSA'
                and rownum < 10
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'FSA_EE_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RN' value rownum,
                                'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'ee_name' value i.person_name,
                                'ee_address' value i.address,
                                'ee_city_state' value i.city,
                                'acc_num' value i.account_number
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[FSA_Employee_Welcome_Letter_Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.account_number
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_fsa_ee;

    procedure wl_fsa_ee_welcome (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/edi/dev';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.119", "port": 22, "user": "ftp_admin", "password": "SterlinGFtP2@!2admIn"}'
            ;
        end if;

        l_file_name := 'FSA_Employee_Welcome_Letter.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'ee_name' value person_name,
                                                key 'ee_address' value nvl(address, ' '),
                                                key 'ee_city_state' value nvl(city, ' '),
                                                key 'acc_num' value account_number
                                    returning clob)
                                returning clob)
                            from
                                subscriber_hra_welcome_letter
                            where
                                    trunc(reg_date) <= trunc(sysdate)
                                and confirmation_date is null
                                and account_type = 'FSA'
                                and rownum < 10
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;

        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[FSA_Employee_Welcome_Letter_Template.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating FSA Employee Welcome Letter'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_fsa_ee_welcome;

    procedure wl_fsa_er is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                replace(er_name, '&', 'and') er_name,
                er_contact,
                address,
                city,
                acc_num
            from
                employer_hra_welcome_letter
            where
                    trunc(start_date) <= trunc(sysdate)
                and acc_num is not null
                and confirmation_date is null
                and account_type = 'HRA'
                and rownum < 10
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'FSA_ER_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RN' value rownum,
                                'er_contact' value i.er_contact,
                                'er_name' value i.er_name,
                                'er_address' value i.address,
                                'er_city_state' value i.city,
                                'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'acc_num' value i.acc_num
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[FSA_Employer_Welcome_Letter_Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.acc_num
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_fsa_er;

    procedure wl_fsa_er_welcome (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'FSA_Employer_Welcome_Letter.pdf';
        pc_log.log_error('get_hsa_quick_view_report', 'start');
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'er_contact' value er_contact,
                                                key 'er_name' value er_name,
                                                key 'er_address' value nvl(address, ' '),
                                                key 'er_city_state' value nvl(city, ' '),
                                                key 'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'acc_num' value acc_num,
                                                key 'pageBreak' value 'true'
                                    returning clob)
                                returning clob)
                            from
                                employer_hra_welcome_letter
                            where
                                    trunc(start_date) <= trunc(sysdate)
                                and acc_num is not null
                                and confirmation_date is null
                                and account_type = 'HRA'
                                and rownum < 10
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
            dbms_output.put_line(l_clob);
        end loop;

        pc_log.log_error('get_hsa_quick_view_report after loop ', l_clob);
        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[FSA_Employer_Welcome_Letter_Template.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating FSA Employer Welcome Letter'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

        pc_log.log_error('get_hsa_quick_view_report after loop ', '**1');
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_fsa_er_welcome;

    procedure wl_hra_ee is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                today,
                person_name,
                address,
                city,
                account_number,
                employer,
                to_char(sysdate, 'YYYY') year,
                account_type,
                lang_perf,
                template_name
            from
                subscriber_hra_welcome_letter
            where
                    trunc(reg_date) <= trunc(sysdate)
                and confirmation_date is null
                and account_type = 'HRA'
                and rownum < 10
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'HRA_EE_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RN' value rownum,
                                'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'ee_name' value i.person_name,
                                'ee_address' value i.address,
                                'ee_city_state' value i.city,
                                'acc_num' value i.account_number
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[FSA_Employee_Welcome_Letter_Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.account_number
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_hra_ee;

    procedure wl_hra_er is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                replace(er_name, '&', 'and') er_name,
                er_contact,
                address,
                city,
                acc_num
            from
                employer_hra_welcome_letter
            where
                    trunc(start_date) <= trunc(sysdate)
                and acc_num is not null
                and confirmation_date is null
                and account_type = 'HRA'
                and rownum < 10
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'HRA_ER_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RN' value rownum,
                                'er_contact' value i.er_contact,
                                'er_name' value i.er_name,
                                'er_address' value i.address,
                                'er_city_state' value i.city,
                                'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'acc_num' value i.acc_num
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[FSA_Employer_Welcome_Letter_Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.acc_num
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_hra_er;

    procedure wl_broker is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                today,
                broker_name,
                nvl(address, ' ') address,
                nvl(city, ' ')    city,
                ltrim(substr(broker_name, 1, 4)
                      || 'Broker')      account_number
            from
                broker_welcome_letter_v
            where
                trunc(start_date) = trunc(sysdate)
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'BROKER_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'today_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'broker_name' value i.broker_name,
                                'broker_address' value i.address,
                                'broker_city_state' value i.city
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Broker_Welcome_Letter_Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.account_number
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_broker;

    procedure wl_broker_welcome (
        p_broker_id in number default null,
        p_output    in varchar2 default 'FTP'
    ) is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'Broker_Welcome_letter.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'BROKER_NAME' value broker_name,
                                                key 'ADDRESS' value nvl(address, ' '),
                                                key 'ADDRESS2' value nvl(city, ' '),
                                                key 'ACCOUNT_NUMBER' value ltrim(substr(broker_name, 1, 4)
                                                                                 || 'Broker')
                                    returning clob)
                                returning clob)
                            from
                                broker_welcome_letter_v
                            where
                                    broker_id = nvl(p_broker_id, broker_id)
                                and(p_broker_id is not null
                                    or(p_broker_id is null
                                       and trunc(start_date) = trunc(sysdate)))
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;      
    --    dbms_output.put_line(l_clob);
        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[Broker_Welcome_Letter_Template.docx]',
                p_output_type     => 'pdf',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       =>
                             case
                                 when p_output = 'FTP' then
                                     'CLOUD'
                                 else
                                     'BROWSER'
                             end,
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating welcome letter File'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_broker_welcome;

    procedure wl_claim_denial is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                table ( pc_notifications.get_claim_deny_letter )
            where
                event_name = 'CLAIM_DENIAL'
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'CLAIM_DENIAL'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RECEIVER_NAME' value i.person_name,
                                'RECEIVER_ADDRESS_LINE1' value i.address,
                                'RECEIVER_ADDRESS_LINE2' value i.address2,
                                'date' value to_char(sysdate, 'MM/DD/YYYY'),
                                'ACCOUNT_NO' value i.acc_num,
                                'EMPLOYER' value i.employer_name,
                                'CLM_NO' value i.claim_id,
                                'CLM_AMT' value i.claim_amount,
                                'AMT_DENIED' value i.denied_amount,
                                'REASONS' value i.denied_reason
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Denial-Letter-Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.acc_num
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_claim_denial;

    procedure wl_claim_denial_welcome (
        p_output in varchar2 default 'FTP'
    ) is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'Claim_Denial_Letter.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'RECEIVER_NAME' value person_name,
                                                key 'RECEIVER_ADDRESS_LINE1' value address,
                                                key 'RECEIVER_ADDRESS_LINE2' value address2,
                                                key 'DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'ACCOUNT_NO' value acc_num,
                                                key 'EMPLOYER' value employer_name,
                                                key 'CLM_NO' value claim_id,
                                                key 'CLM_AMT' value format_money(claim_amount),
                                                key 'AMT_DENIED' value format_money(denied_amount),
                                                key 'REASONS' value denied_reason,
                                                key 'pageBreak' value 'true'
                                    returning clob)
                                returning clob)
                            from
                                table(pc_notifications.get_claim_deny_letter)
                            where
                                event_name = 'CLAIM_DENIAL'
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;

        dbms_output.put_line(l_clob);
        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[Denial-Letter-Template.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;

    --	mail_utility.send_email('webservice@sterlingadministration.com','vanitha.subramanyam@sterlingadministration.com',
    --                                    'Error in Creating Claim denial letter File', l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_claim_denial_welcome;

    procedure wl_partial_claim_denial_letters as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                partial_claim_denial_letters_v
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'PARTIAL_CLAIM_DENIAL_LETTERS'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'RECEIVER_NAME' value i.employer_name,
                                'RECEIVER_ADDRESS_LINE1' value i.address,
                                'RECEIVER_ADDRESS_LINE2' value i.address2,
                                'DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                'ACCOUNT_NO' value i.acc_num,
                                'EMPLOYER' value i.employer_name,
                                'CLM_NO' value i.claim_id,
                                'CLM_AMT' value i.claim_amount,
                                'AMT_DED' value i.deductible_amount,
                                'AMT_DEN' value i.denied_amount,
                                'AMT_PE' value i.claim_pending,
                                'A_PAID' value i.claim_paid,
                                'REASONS' value i.denied_reason
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[Partial-Payment-Letter-Template.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', i.acc_num
                                                                                                                                     || '-'
                                                                                                                                     || l_sqlerrm
                                                                                                                                     )
                                                                                                                                     ;

                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_partial_claim_denial_letters;

    procedure wl_partial_claim_denial_letters_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    ) as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'Partial_Claim_Denial_letters.pdf';
        dbms_output.put_line('p_claim_id: ' || p_claim_id);
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'RECEIVER_NAME' value employer_name,
                                                key 'RECEIVER_ADDRESS_LINE1' value address,
                                                key 'RECEIVER_ADDRESS_LINE2' value address2,
                                                key 'DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'ACCOUNT_NO' value acc_num,
                                                key 'EMPLOYER' value employer_name,
                                                key 'CLM_NO' value claim_id,
                                                key 'CLM_AMT' value format_money(claim_amount),
                                                key 'AMT_DED' value format_money(deductible_amount),
                                                key 'AMT_DEN' value format_money(denied_amount),
                                                key 'AMT_PE' value format_money(claim_pending),
                                                key 'A_PAID' value format_money(claim_paid),
                                                key 'REASONS' value denied_reason,
                                                key 'pageBreak' value 'true'
                                    returning clob)
                                returning clob)
                            from
                                partial_claim_denial_letters_v
                            where
                                claim_id = nvl(p_claim_id, claim_id)
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;

        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[Partial-Payment-Letter-Template.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating partial claim denial letters'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_partial_claim_denial_letters_welcome;

    procedure wl_second_letter_insufficient as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                debit_card_second_letter_v
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'SECOND_LETTER_INSUFFICIENT_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                'EMPLOYEE_NAME' value i.name,
                                'ADDRESS' value i.address,
                                'CITY' value i.city,
                                'STATE' value i.state,
                                'ZIP_CODE' value i.zip,
                                'CLAIM_NUMBER' value i.claim_id,
                                'DATE_OF_SERVICE' value i.service_date,
                                'PROVIDER' value i.provider_name,
                                'AMOUNT' value i.amount
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[SECOND_LETTER_INSUFFICIENT_DOC_OR_NOT_RECEIVED_TEMPLATE.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', l_sqlerrm);
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_second_letter_insufficient;

    procedure wl_second_letter_insufficient_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    ) as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'Second_Letter_Insufficient.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'EMPLOYEE_NAME' value name,
                                                key 'ADDRESS' value address,
                                                key 'CITY' value city,
                                                key 'STATE' value state,
                                                key 'ZIP_CODE' value zip,
                                                key 'CLAIM_NUMBER' value claim_id,
                                                key 'DATE_OF_SERVICE' value service_date,
                                                key 'PROVIDER' value provider_name,
                                                key 'AMOUNT' value format_money(amount),
                                                key 'pageBreak' value 'true'
                                    returning clob)
                                returning clob)
                            from
                                debit_card_second_letter_v
                            where
                                claim_id = nvl(p_claim_id, claim_id)
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
            dbms_output.put_line(l_clob);
        end loop;

        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[SECOND_LETTER_INSUFFICIENT_DOC_OR_NOT_RECEIVED_TEMPLATE.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating Second letter insufficient letter File'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_second_letter_insufficient_welcome;

    procedure wl_last_letter_debit_card as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                debit_card_last_letter_v
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'LAST_LETTER_DEBIT_CARD_'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                'EMPLOYEE_NAME' value i.name,
                                'ADDRESS' value i.address,
                                'CITY' value i.city,
                                'STATE' value i.state,
                                'ZIP_CODE' value i.zip,
                                'CLAIM_NUMBER' value i.claim_id,
                                'DATE_OF_SERVICE' value i.service_date,
                                'PROVIDER' value i.provider_name,
                                'AMOUNT' value i.amount
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[FIRST_LETTER_ADDITIONAL_DOC_REQUIRED_TEMPLATE.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', l_sqlerrm);
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_last_letter_debit_card;

    procedure wl_last_letter_debit_card_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    ) as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        dbms_output.put_line('debug 1');
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        dbms_output.put_line('debug 2');
        l_file_name := 'Last_Letter_Debit_Card.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'EMPLOYEE_NAME' value name,
                                                key 'ADDRESS' value address,
                                                key 'CITY' value city,
                                                key 'STATE' value state,
                                                key 'ZIP_CODE' value zip,
                                                key 'CLAIM_NUMBER' value claim_id,
                                                key 'DATE_OF_SERVICE' value service_date,
                                                key 'PROVIDER' value provider_name,
                                                key 'AMOUNT' value format_money(amount),
                                                key 'pageBreak' value 'true'
                                    returning clob)
                                returning clob)
                            from
                                debit_card_last_letter_v
                            where
                                claim_id = nvl(p_claim_id, claim_id)
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
            dbms_output.put_line('debug 3');
        end loop;

        dbms_output.put_line('debug 4');
        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[LAST_LETTER_DEBIT_CARD_INACTIVE_TEMPLATE.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating Last debit card Letter '
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_last_letter_debit_card_welcome;

    procedure wl_debit_card_adj_letters as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        for i in (
            select
                *
            from
                debit_card_first_letter_v
        ) loop
            begin
                aop_api_pkg.g_cloud_provider := 'sftp';
                aop_api_pkg.g_cloud_location := '/home/ftp_admin';
                aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
                ;
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'DEBIT_CARD_ADJ_LETTERS'
                               || l_file_id
                               || '_ssn';
                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                select
                    json_object(
                        'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                'EMPLOYEE_NAME' value i.name,
                                'ADDRESS' value i.address,
                                'CITY' value i.city,
                                'STATE' value i.state,
                                'ZIP_CODE' value i.zip,
                                'CLAIM_NUMBER' value i.claim_id,
                                'DATE_OF_SERVICE' value i.service_date,
                                'PROVIDER' value i.provider_name,
                                'AMOUNT' value i.amount
                    returning clob)
                into l_clob
                from
                    dual;

                l_return := aop_api_pkg.plsql_call_to_aop(
                    p_data_type       => 'JSON',
                    p_data_source     => l_clob,
                    p_template_type   => 'APEX',
                    p_template_source => q'[FIRST_LETTER_ADDITIONAL_DOC_REQUIRED_TEMPLATE.docx]',
                    p_output_type     => 'PDF',
                    p_output_filename => l_file_name,
                    p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                    p_output_to       => 'CLOUD',
                    p_aop_url         => 'http://172.24.16.116:8010/',
                    p_app_id          => 203
                );

            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com'
                    , 'Error in Creating SSN batch File', l_sqlerrm);
                    dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
            end;
        end loop;
    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_debit_card_adj_letters;

    procedure wl_debit_card_adj_letters_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    ) as

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        if p_output = 'FTP' then
            aop_api_pkg.g_cloud_provider := 'sftp';
            aop_api_pkg.g_cloud_location := '/home/ftp_admin';
            aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.115", "port": 22, "user": "ftp_admin", "password": "5rd$eSzAw3yHn"}'
            ;
        end if;

        l_file_name := 'Debit_Card_Adj_Letters.pdf';
        for i in (
            select
                json_array(
                    json_object(
                        key 'WELCOME_T' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                                key 'EMPLOYEE_NAME' value name,
                                                key 'ADDRESS' value address,
                                                key 'CITY' value city,
                                                key 'STATE' value state,
                                                key 'ZIP_CODE' value zip,
                                                key 'CLAIM_NUMBER' value claim_id,
                                                key 'DATE_OF_SERVICE' value service_date,
                                                key 'PROVIDER' value provider_name,
                                                key 'AMOUNT' value format_money(amount),
                                                key 'pageBreak' value 'true'
                                    returning clob)
                                returning clob)
                            from
                                debit_card_first_letter_v
                            where
                                claim_id = nvl(p_claim_id, claim_id)
                        )
                    returning clob)
                returning clob) b_letter
            from
                dual
        ) loop
            l_clob := i.b_letter;
        end loop;

        begin
            l_return := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => 'JSON',
                p_data_source     => l_clob,
                p_template_type   => 'APEX',
                p_template_source => q'[FIRST_LETTER_ADDITIONAL_DOC_REQUIRED_TEMPLATE.docx]',
                p_output_type     => 'PDF',
                p_output_filename => l_file_name,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_output_to       => 'CLOUD',
                p_aop_url         => 'http://172.24.16.116:8010/',
                p_app_id          => 203
            );
        exception
            when others then
                l_sqlerrm := sqlerrm;
                mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating Debit Card Adj letter'
                , l_sqlerrm);
                dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
        end;

    exception
        when others then
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end wl_debit_card_adj_letters_welcome;

    function get_hsa_quick_view_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob is
        l_clob clob;
    begin
--     pc_log.log_error('get_hsa_quick_view_report','entrp_id'||p_entrp_id);
--     pc_log.log_error('get_hsa_quick_view_report','p_division_code'||p_division_code);
--     pc_log.log_error('get_hsa_quick_view_report','p_month'||p_month);
--     pc_log.log_error('get_hsa_quick_view_report','p_year'||p_year);
        execute immediate 'alter session set nls_date_format=''DD-MON-yyyy'' ';
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'HSA-QUICK-VIEW'
                                             || p_entrp_id
                                             || '.pdf',
                                key 'data' value
                            json_object(
                                key 'CURRENT_MONTH' value p_month,
                                        key 'ACC_NUM' value acc_num,
                                        key 'NAME' value name,
                                        key 'ADDRESS' value address,
                                        key 'ADDRESS2' value address2,
                                        key 'DIVISION_NAME' value division_name,
                                        key 'ACC_BAL' value acc_bal,
                                        key 'OUTSIDE_BAL' value inv_bal,
                                        key 'ALL_EE' value all_ee,
                                        key 'OPEN_ACC' value open_ee,
                                        key 'PENDING_ACC' value p_ee,
                                        key 'CLOSED_ACC' value c_ee,
                                        key 'INV_ACC' value inv_ee,
                                        key 'OPEN_PER' value round((open_ee / case
                                    when all_ee = 0 then
                                        1
                                    else all_ee
                                end) * 100, 2),
                                        key 'PEN_PER' value round((p_ee / case
                                    when all_p = 0 then
                                        1
                                    else all_p
                                end) * 100, 2),
                                        key 'CLOSED_PER' value round((c_ee / case
                                    when all_c = 0 then
                                        1
                                    else all_c
                                end) * 100, 2),
                                        key 'INV_PER' value round((inv_ee / case
                                    when all_inv = 0 then
                                        1
                                    else all_inv
                                end) * 100, 2),
                                        key 'ALL_PENDING_ACC' value all_p,
                                        key 'ALL_CLOSED_ACC' value all_c,
                                        key 'ALL_INV_ACC' value all_inv,
                                        key 'CARD_COUNT' value c_card,
                                        key 'CARD_NA_COUNT' value cna_card,
                                        key 'BEN_COUNT' value c_ben,
                                        key 'USER_COUNT' value user_cnt,
                                        key 'EMAIL_COUNT' value email_cnt,
                                        key 'CARD_PER' value round((c_card / case
                                    when all_ee = 0 then
                                        1
                                    else all_ee
                                end) * 100, 2),
                                        key 'CNA_PER' value round((cna_card / case
                                    when all_ee = 0 then
                                        1
                                    else all_ee
                                end) * 100, 2),
                                        key 'BEN_PER' value round((c_ben / case
                                    when all_ee = 0 then
                                        1
                                    else all_ee
                                end) * 100, 2),
                                        key 'USER_PER' value round((user_cnt / case
                                    when all_ee = 0 then
                                        1
                                    else all_ee
                                end) * 100, 2),
                                        key 'EMAIL_PER' value round((email_cnt / case
                                    when all_ee = 0 then
                                        1
                                    else all_ee
                                end) * 100, 2)
                            )
                    returning clob)
                returning clob) files
            from
                (
                    select
                        b.entrp_id,
                        to_char(sysdate, 'MM/DD/YYYY')                                       curr_dt,
                        b.acc_num,
                        e.name,
                        e.address,
                        e.city
                        || ' '
                        || e.state
                        || ' '
                        || e.zip                                                             address2,
                        pc_employer_divisions.get_division_name(p_division_code, e.entrp_id) division_name,
                        nvl(
                            pc_reports_pkg.get_acc_balance(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    acc_bal,
                        nvl(
                            pc_reports_pkg.get_acc_inv_bal(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    inv_bal,
                        nvl(
                            pc_reports_pkg.get_all_acc_count(e.entrp_id, p_division_code, null),
                            0
                        )                                                                    all_ee,
                        nvl(
                            pc_reports_pkg.get_acc_count(e.entrp_id, p_division_code, p_month, p_year, null),
                            0
                        )                                                                    open_ee,
                        nvl(
                            pc_reports_pkg.get_acc_count(e.entrp_id, p_division_code, p_month, p_year, 'PENDING'),
                            0
                        )                                                                    p_ee,
                        nvl(
                            pc_reports_pkg.get_acc_count(e.entrp_id, p_division_code, p_month, p_year, 'CLOSED'),
                            0
                        )                                                                    c_ee,
                        nvl(
                            pc_reports_pkg.get_acc_count(e.entrp_id, p_division_code, p_month, p_year, 'INV'),
                            0
                        )                                                                    inv_ee,
                        nvl(
                            pc_reports_pkg.get_all_acc_count(e.entrp_id, p_division_code, 'PENDING'),
                            0
                        )                                                                    all_p,
                        nvl(
                            pc_reports_pkg.get_all_acc_count(e.entrp_id, p_division_code, 'CLOSED'),
                            0
                        )                                                                    all_c,
                        nvl(
                            pc_reports_pkg.get_all_acc_count(e.entrp_id, p_division_code, 'INV'),
                            0
                        )                                                                    all_inv,
                        nvl(
                            pc_reports_pkg.get_card_count(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    c_card,
                        nvl(
                            pc_reports_pkg.get_card_not_active_count(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    cna_card,
                        nvl(
                            pc_reports_pkg.get_ben_count(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    c_ben,
                        nvl(
                            pc_reports_pkg.get_active_user_count(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    user_cnt,
                        nvl(
                            pc_reports_pkg.get_acc_email_count(e.entrp_id, p_division_code, p_month, p_year),
                            0
                        )                                                                    email_cnt
                    from
                        enterprise e,
                        account    b
                    where
                            e.entrp_id = b.entrp_id
                        and b.entrp_id = p_entrp_id
                )
        ) loop
            l_clob := x.files;
        end loop;

        return l_clob;
    end get_hsa_quick_view_report;

    function get_spender_saver_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob is
        l_clob clob;
    begin
 --    pc_log.log_error('get_spender_saver_report','entrp_id'||p_entrp_id);
--     pc_log.log_error('get_spender_saver_report','p_division_code'||p_division_code);
 --    pc_log.log_error('get_spender_saver_report','p_month'||p_month);
 --    pc_log.log_error('get_spender_saver_report','p_year'||p_year);
        execute immediate 'alter session set nls_date_format=''DD-MON-yyyy'' ';
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'spender_saver.pdf',
                                key 'data' value
                            json_object(
                                key 'CURRENT_MONTH' value p_month,
                                        key 'ACC_NUM' value a.acc_num,
                                        key 'NAME' value e.name,
                                        key 'ADDRESS' value e.address,
                                        key 'ADDRESS2' value e.city
                                                             || ' '
                                                             || e.state
                                                             || ' '
                                                             || e.zip,
                                        key 'DIVISION_NAME' value pc_employer_divisions.get_division_name(null, e.entrp_id),
                                        key 'SPEND_SAVE_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'TRANSACTION_TYPE' value transaction_type,
                                                key 'DESCRIPTION' value description,
                                                key 'NO_OF_TXNS' value no_of_txns,
                                                key 'PERC_OF_TXNS' value perc_of_txns
                                            returning clob)
                                        returning clob)
                                    from
                                        table(pc_reports_pkg.get_spender_saver_summary(e.entrp_id, null, p_month, p_year)) t
                                ),
                                        key 'chart' value(
                                    select
                                        json_array(
                                            json_object(
                                                key 'type' value 'pie3d',
                                                        key 'name' value 'Spender Saver',
                                                        key 'options' value json_array(
                                                        json_object(
                                                        key 'width' value 576,
                                                        key 'height' value 336,
                                                        key 'title_x0020_in_x0020_chart' value 'Spender Saver',
                                                        key 'grid' value 'true',
                                                        key 'border' value 'true'
                                                    )
                                                ),
                                                        key 'pies' value json_arrayagg(
                                                        json_object(
                                                        key 'name' value 'pie',
                                                                key 'data' value(
                                                            select
                                                                json_arrayagg(
                                                                    json_object(
                                                                        key 'x' value description,
                                                                        key 'y' value no_of_txns
                                                                    returning clob)
                                                                returning clob)
                                                            from
                                                                table(pc_reports_pkg.get_spender_saver_summary(e.entrp_id, null, p_month
                                                                , p_year)) t
                                                        )
                                                    )
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        dual
                                )
                            returning clob)
                    returning clob)
                ) files
            from
                enterprise e,
                account    a
            where
                    e.entrp_id = a.entrp_id
                and a.entrp_id = p_entrp_id
        ) loop
            l_clob := x.files;
        end loop;

        return l_clob;
    end get_spender_saver_report;

    function balance_breakdown_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob is
        l_clob clob;
    begin
--     pc_log.log_error('balance_breakdown_report','entrp_id'||p_entrp_id);
--     pc_log.log_error('balance_breakdown_report','p_division_code'||p_division_code);
--     pc_log.log_error('balance_breakdown_report','p_month'||p_month);
--     pc_log.log_error('balance_breakdown_report','p_year'||p_year);
        execute immediate 'alter session set nls_date_format=''DD-MON-yyyy'' ';
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'balance-range.pdf',
                                key 'data' value
                            json_object(
                                key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ACC_NUM' value a.acc_num,
                                        key 'NAME' value e.name,
                                        key 'ADDRESS' value e.address,
                                        key 'ADDRESS2' value e.city
                                                             || ' '
                                                             || e.state
                                                             || ' '
                                                             || e.zip,
                                        key 'DIVISION_NAME' value pc_employer_divisions.get_division_name(null, e.entrp_id),
                                        key 'NO_OF_EMPLOYES' value pc_reports_pkg.get_all_acc_count(e.entrp_id, null, null, p_month, p_year
                                        ),
                                        key 'BAL_RANGE_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'BAL_RANGE' value description,
                                                        key 'ACC' value no_of_accounts,
                                                        key 'TOTAL' value format_money(total_amount),
                                                        key 'AVG_BAL' value format_money(avg_bal),
                                                        key 'PER_ACC' value perc_account
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select
                                                description,
                                                total_amount,
                                                perc_account,
                                                no_of_accounts,
                                                sum(total_amount)
                                                over(partition by 1) avg_bal
                                            from
                                                table(pc_reports_pkg.get_balance_range(e.entrp_id, null, p_month, p_year))
                                        ) t
                                ),
                                        key 'INV_BAL_RANGE_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'INV_BAL_RANGE' value description,
                                                        key 'INV_ACC' value no_of_accounts,
                                                        key 'INV_TOTAL' value format_money(total_amount),
                                                        key 'AVG_INV' value format_money(avg_inv),
                                                        key 'INV_PER_ACC' value perc_account
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select
                                                description,
                                                total_amount,
                                                perc_account,
                                                no_of_accounts,
                                                sum(total_amount)
                                                over(partition by 1) avg_inv
                                            from
                                                table(pc_reports_pkg.get_outside_inv_range(e.entrp_id, null, p_month, p_year))
                                        ) t
                                ),
                                        key 'TOT_BAL_RANGE_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'TO_BAL_RANGE' value description,
                                                        key 'TO_ACC' value no_of_accounts,
                                                        key 'TO_TOTAL' value format_money(total_amount),
                                                        key 'AVG_TOT' value format_money(avg_tot),
                                                        key 'TO_PER_ACC' value perc_account
                                            returning clob)
                                        returning clob)
                                    from
                                        (
                                            select
                                                description,
                                                total_amount,
                                                perc_account,
                                                no_of_accounts,
                                                sum(total_amount)
                                                over(partition by 1) avg_tot
                                            from
                                                table(pc_reports_pkg.get_total_bal_range(e.entrp_id, null, p_month, p_year))
                                        ) t
                                ),
                                        key 'BAL_CHART' value(
                                    select
                                        json_array(
                                            json_object(
                                                key 'type' value 'pie3d',
                                                        key 'name' value 'Balance Ranger',
                                                        key 'options' value json_array(
                                                        json_object(
                                                        key 'width' value 576,
                                                        key 'height' value 336,
                                                        key 'title_x0020_in_x0020_chart' value 'Balance Range',
                                                        key 'grid' value 'true',
                                                        key 'border' value 'true'
                                                    )
                                                ),
                                                        key 'pies' value json_arrayagg(
                                                        json_object(
                                                        key 'name' value 'pie',
                                                                key 'data' value(
                                                            select
                                                                json_arrayagg(
                                                                    json_object(
                                                                        key 'x' value description,
                                                                        key 'y' value no_of_accounts
                                                                    returning clob)
                                                                returning clob)
                                                            from
                                                                table(pc_reports_pkg.get_balance_range(e.entrp_id, null, p_month, p_year
                                                                )) t
                                                        )
                                                    )
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        dual
                                ),
                                        key 'TOT_CHART' value(
                                    select
                                        json_array(
                                            json_object(
                                                key 'type' value 'pie3d',
                                                        key 'name' value 'Total Balance Range Summary',
                                                        key 'options' value json_array(
                                                        json_object(
                                                        key 'width' value 576,
                                                        key 'height' value 336,
                                                        key 'title_x0020_in_x0020_chart' value 'Balance Range',
                                                        key 'grid' value 'true',
                                                        key 'border' value 'true'
                                                    )
                                                ),
                                                        key 'pies' value json_arrayagg(
                                                        json_object(
                                                        key 'name' value 'pie',
                                                                key 'data' value(
                                                            select
                                                                json_arrayagg(
                                                                    json_object(
                                                                        key 'x' value description,
                                                                        key 'y' value no_of_accounts
                                                                    returning clob)
                                                                returning clob)
                                                            from
                                                                table(pc_reports_pkg.get_total_bal_range(e.entrp_id, null, p_month, p_year
                                                                )) t
                                                        )
                                                    )
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        dual
                                )
                            returning clob)
                    returning clob)
                ) files
            from
                enterprise e,
                account    a
            where
                    e.entrp_id = a.entrp_id
                and a.entrp_id = p_entrp_id
        ) loop
            l_clob := x.files;
        end loop;

        return l_clob;
    end balance_breakdown_report;

    function contribution_disbursement_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob is
        l_clob clob;
    begin
 --    pc_log.log_error('get_spender_saver_report','entrp_id'||p_entrp_id);
--     pc_log.log_error('get_spender_saver_report','p_division_code'||p_division_code);
 --    pc_log.log_error('get_spender_saver_report','p_month'||p_month);
 --    pc_log.log_error('get_spender_saver_report','p_year'||p_year);
        execute immediate 'alter session set nls_date_format=''DD-MON-yyyy'' ';
        for x in (
            select
                json_arrayagg(
                    json_object(
                        key 'FILENAME' value 'contr-disb.pdf',
                                key 'data' value
                            json_object(
                                key 'CURRENT_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ACC_NUM' value a.acc_num,
                                        key 'NAME' value e.name,
                                        key 'ADDRESS' value e.address,
                                        key 'ADDRESS2' value e.city
                                                             || ' '
                                                             || e.state
                                                             || ' '
                                                             || e.zip,
                                        key 'DIVISION_NAME' value pc_employer_divisions.get_division_name(null, e.entrp_id),
                                        key 'NO_OF_EMPLOYES' value pc_reports_pkg.get_all_acc_count(e.entrp_id, null, null, p_month, p_year
                                        ),
                                        key 'D_SUMM_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'D_SUMM_DESC' value description,
                                                        key 'D_NO_OF_TXNS' value no_of_txns,
                                                        key 'D_TOTAL' value format_money(total_amount),
                                                        key 'D_AVG_BAL' value format_money(avg_amount)
                                            returning clob)
                                        returning clob)
                                    from
                                        table(pc_reports_pkg.get_disbursement_summary(e.entrp_id, null, p_month, p_year)) t
                                ),
                                        key 'Y_D_SUMM_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'Y_D_SUMM_DESC' value description,
                                                        key 'Y_D_N_TXNS' value no_of_txns,
                                                        key 'Y_D_TOT' value format_money(total_amount),
                                                        key 'Y_D_AVG_BAL' value format_money(avg_amount)
                                            returning clob)
                                        returning clob)
                                    from
                                        table(pc_reports_pkg.get_ytd_disbursement_summary(e.entrp_id, null, p_month, p_year)) t
                                ),
                                        key 'CONTR_SUMMARY_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'C_SUMM_DESC' value description,
                                                        key 'C_NO_OF_TXNS' value no_of_txns,
                                                        key 'C_TOTAL' value format_money(total_amount),
                                                        key 'C_AVG_BAL' value format_money(avg_amount)
                                            returning clob)
                                        returning clob)
                                    from
                                        table(pc_reports_pkg.get_contribution_summary(e.entrp_id, null, p_month, p_year)) t
                                ),
                                        key 'YTD_C_SUM_T' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'Y_C_SUMM_DESC' value description,
                                                        key 'Y_C_N_TXNS' value no_of_txns,
                                                        key 'Y_C_TOT' value format_money(total_amount),
                                                        key 'Y_C_AVG_BAL' value format_money(avg_amount)
                                            returning clob)
                                        returning clob)
                                    from
                                        table(pc_reports_pkg.get_ytd_contribution_summary(e.entrp_id, null, p_month, p_year)) t
                                ),
                                        key 'COLCHART' value(
                                    select
                                        json_array(
                                            json_object(
                                                key 'type' value 'column',
                                                        key 'name' value 'Contribution Summary',
                                                        key 'options' value json_array(
                                                        json_object(
                                                        key 'width' value 576,
                                                        key 'height' value 336,
                                                        key 'title' value 'Contribution Summary',
                                                        key 'grid' value 'true',
                                                        key 'border' value 'true'
                                                    )
                                                ),
                                                        key 'columns' value json_arrayagg(
                                                        json_object(
                                                        key 'name' value 'contribution',
                                                                key 'data' value(
                                                            select
                                                                json_arrayagg(
                                                                    json_object(
                                                                        key 'x' value description,
                                                                        key 'y' value total_amount  --check with Vanitha need to get this value from get_YTD_contribution_summary.total_amount
                                                                    returning clob)
                                                                returning clob)
                                                            from
                                                                table(pc_reports_pkg.get_ytd_contribution_summary(e.entrp_id, null, p_month
                                                                , p_year)) t
                                                        )
                                                    )
                                                )
                                            returning clob)
                                        returning clob)
                                    from
                                        dual
                                )
                            returning clob)
                    returning clob)
                ) files
            from
                enterprise e,
                account    a
            where
                    e.entrp_id = a.entrp_id
                and a.entrp_id = p_entrp_id
        ) loop
            l_clob := x.files;
        end loop;

        return l_clob;
    end contribution_disbursement_report;

end pc_office_reports;
/

