create or replace force editionable view samqa.external_5498_v (
    account_number,
    name,
    address,
    city,
    state,
    zip,
    ssn,
    box1,
    box2,
    box3,
    box4,
    box5,
    box6
) as
    select
        account_number,
        name,
        address,
        city,
        state,
        zip,
        ssn,
        0   box1,
        box2,
        box3,
        box4,
        case
            when box5 < 0 then
                0
            else
                box5
        end box5,
        'Y' box6
    from
        (
            select
                account_number,
                name,
                address,
                city,
                state,
                zip,
                ssn,
                0                                                box1
  --   , DEPOSIT +CATCHUP+PREVYEAR -ACC_MAINT box2
                ,
                deposit + catchup + prevyear                     box2,
                taxyear                                          box3,
                rollover                                         box4,
                pc_account.current_balance(account_id,
                                           '01-JAN-2004',
                                           round(sysdate, 'YYYY') - 1) + outside box5,
                'Y'
            from
                (
                    select
                        replace(u_name, ',', ' ')                                            name,
                        address,
                        city,
                        state,
                        zip,
                        ssn,
                        acc_num                                                              account_number,
                        acc_id                                                               account_id,
                        age                                                                  age,
                        decode(coverage, 'F', 'Family Coverage', 'I', 'Individual Coverage') coverage,
                        deductible,
                        decode(coverage,
                               'F',
                               pc_param.get_system_value('FAMILY_CONTRIBUTION',
                                                         round(sysdate, 'YYYY') - 1),
                               'I',
                               pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION',
                                                         round(sysdate, 'YYYY') - 1))                         fed_max,
                        case
                            when age >= 55 then
                                pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                          round(sysdate, 'YYYY') - 1)
                            else
                                '0'
                        end                                                                  catchup_contribution,
                        start_date,
                        case
                            when to_number(to_char(start_date, 'YYYY')) < to_number(to_char(round(sysdate, 'YYYY') - 1,
                                                                                            'YYYY')) then
                                1
                            when to_number(to_char(start_date, 'YYYY')) = to_number(to_char(round(sysdate, 'YYYY') - 1,
                                                                                            'YYYY')) then
                                ( 13 - to_number(to_char(start_date, 'MM')) ) / 12
                        end                                                                  proration,
                        nvl(deposit, 0) + nvl(adjustment, 0)                                 deposit,
                        nvl(rollover, 0)                                                     rollover,
                        nvl(taxyear, 0)                                                      taxyear
	  --   , NVL(DISBURSEMENT,0) DISBURSEMENT
	  --   , NVL(ACCOUNT_FEES,0) ACCOUNT_FEES
	  --   , NVL(ACC_MAINT,0) ACC_MAINT
                        ,
                        nvl(outside, 0)                                                      outside,
                        nvl(catchup, 0)                                                      catchup,
                        nvl(prevyear, 0)                                                     prevyear
                    from
                        (
                            select
                                person.first_name
                                || ' '
                                || person.middle_name
                                || ' '
                                || person.last_name                                    u_name,
                                person.address                                         address,
                                person.city,
                                person.state,
                                person.zip,
                                person.ssn,
                                l_acc.acc_num                                          acc_num,
                                l_acc.acc_id,
                                person.birth_date                                      birth_date,
                                round(months_between(sysdate, person.birth_date) / 12) age,
                                case
                                    when (
                                        select
                                            count(pers_main)
                                        from
                                            person a
                                        where
                                            a.pers_main = person.pers_id
                                    ) > 0 then
                                        'F'
                                    else
                                        'I'
                                end                                                    coverage,
                                insure.deductible,
                                insure.start_date,
                                nvl(deposit, 0)                                        deposit,
                                nvl(rollover, 0)                                       rollover,
                                nvl(catchup, 0)                                        catchup,
                                nvl(prevyear, 0)                                       prevyear,
                                (
                                    select
                                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                                    from
                                        income
                                    where
                                        fee_code in ( 7, 10 )
                                        and acc_id = l_acc.acc_id
                                        and fee_date between round(sysdate, 'YYYY') and round(sysdate, 'YYYY') + 118
                                )                                                      taxyear,
                                (
                                    select
                                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                                    from
                                        income
                                    where
                                            fee_code = 130
                                        and acc_id = l_acc.acc_id
                                        and fee_date between round(round(sysdate, 'YYYY') - 1,
                                                                   'YYYY') and round(sysdate, 'YYYY') + 118
                                )                                                      adjustment,
                                invest.out_inv                                         outside/*,
		   PAY.ACC_MAINT,
	           PAY.ACCOUNT_FEES,
	           PAY.DISBURSEMENT*/
                            from
                                person  person,
                                insure,
                                account l_acc,
                                (
                                    select
                                        acc_id,
                                        sum(nvl(deposit, 0))  deposit,
                                        sum(nvl(catchup, 0))  catchup,
                                        sum(nvl(rollover, 0)) rollover,
                                        sum(nvl(prevyear, 0)) prevyear
                                    from
                                        (
                                            select
                                                acc_id,
                                                nvl(
                                                    decode(
                                                        nvl(fee_code, 3),
                                                        3,
                                                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                                                    ),
                                                    0
                                                ) + nvl(
                                                    decode(fee_code,
                                                           4,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(fee_code,
                                                           0,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) deposit,
                                                nvl(
                                                    decode(fee_code,
                                                           5,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) rollover,
                                                nvl(
                                                    decode(fee_code,
                                                           6,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) catchup,
                                                nvl(
                                                    decode(fee_code,
                                                           7,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(fee_code,
                                                           10,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) prevyear
                                            from
                                                income
                                            where
                                                ( fee_code is null
                                                  or fee_code in ( 3, 4, 5, 6, 7,
                                                                   0 ) )
                                                and fee_date between trunc((round(sysdate, 'YYYY') - 1),
                                                                           'YYYY') and round(sysdate, 'YYYY') - 1
                                            group by
                                                acc_id,
                                                contributor,
                                                fee_code
                                        )
                                    group by
                                        acc_id
                                )       acc,
		/*(SELECT ACC_ID, SUM(NVL(ACCOUNT_FEES,0)) ACCOUNT_FEES
		     ,  SUM(NVL(DISBURSEMENT,0)) DISBURSEMENT
                     ,  SUM(NVL(ACC_MAINT,0)) ACC_MAINT
		 FROM  ( SELECT   ACC_ID,     NVL(DECODE (REASON_CODE , 1  , 
		                SUM(NVL(AMOUNT,0))),0)
			    +	NVL(DECODE (REASON_CODE , 2  , SUM(NVL(AMOUNT,0))),0) 
			    +   NVL(DECODE (REASON_CODE , 15 , SUM(NVL(AMOUNT,0))),0)  
			    +   NVL(DECODE (REASON_CODE , 17 , SUM(NVL(AMOUNT,0))),0)  ACCOUNT_FEES,
                                NVL(DECODE (REASON_CODE , 1  , 
		                SUM(NVL(AMOUNT,0))),0)
			    +	NVL(DECODE (REASON_CODE , 2  , SUM(NVL(AMOUNT,0))),0)  ACC_MAINT,
				NVL(DECODE (REASON_CODE , 16 , SUM(NVL(AMOUNT,0))),0)
			    +	NVL(DECODE (REASON_CODE , 19 , SUM(NVL(AMOUNT,0))),0)
			    +   NVL(DECODE (REASON_CODE , 0  , SUM(NVL(AMOUNT,0))),0)
			    +   NVL(DECODE (REASON_CODE , 11 , SUM(NVL(AMOUNT,0))),0)
			    +	NVL(DECODE (REASON_CODE , 12 , SUM(NVL(AMOUNT,0))),0)
			    +   NVL(DECODE (REASON_CODE , 13 , SUM(NVL(AMOUNT,0))),0)
			    +   NVL(DECODE (REASON_CODE , 14 , SUM(NVL(AMOUNT,0))),0)
			    +   NVL(DECODE (REASON_CODE , 18 , SUM(NVL(AMOUNT,0))),0)  DISBURSEMENT 
			 FROM   PAYMENT
			WHERE PAY_DATE BETWEEN trunc((ROUND(SYSDATE,'YYYY')-1),'YYYY')
			 AND ROUND(SYSDATE,'YYYY')-1		     
			GROUP BY ACC_ID, REASON_CODE ) 
		 GROUP BY ACC_ID) PAY,*/
                                (
                                    select
                                        invest_transfer.invest_amount out_inv,
                                        acc_id
                                    from
                                        investment      invest,
                                        invest_transfer invest_transfer
                                    where
                                            invest_transfer.investment_id = invest.investment_id
                                        and invest_date = round(sysdate, 'YYYY') - 1
                                )       invest
                            where
                                    insure.pers_id = person.pers_id
                                and insure.start_date < round(sysdate, 'YYYY')
                                and l_acc.account_type = 'HSA'
                                and l_acc.pers_id = person.pers_id (+)
                                and l_acc.acc_id = acc.acc_id (+)
                                and l_acc.acc_id = invest.acc_id (+)
    --AND    L_ACC.ACC_ID   = PAY.ACC_ID(+) 
                        )
                )
        )
    where
        box2 + box3 > 0;


-- sqlcl_snapshot {"hash":"ba478819993845b2a51c34e0636979cffac98bce","type":"VIEW","name":"EXTERNAL_5498_V","schemaName":"SAMQA","sxml":""}