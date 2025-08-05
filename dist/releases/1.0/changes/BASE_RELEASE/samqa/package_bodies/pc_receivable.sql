-- liquibase formatted sql
-- changeset SAMQA:1754374074798 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_receivable.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_receivable.sql:null:157694e21b67090340df30e49bef30902e454525:create

create or replace package body samqa.pc_receivable as

/*  PROCEDURE   INSERT_RECEIVABLE_BATCH (P_BATCH_NUMBER  IN VARCHAR2
                                      ,P_SOURCE_SYSTEM IN VARCHAR2
                                      ,P_SOURCE_TYPE   IN VARCHAR2
                                      ,P_AMOUNT        IN NUMBER
                                      ,P_STATUS        IN VARCHAR2
                                      ,P_START_DATE    IN DATE
                                      ,P_END_DATE      IN DATE
                                      ,P_USER_ID       IN NUMBER
                                      ,X_RECEIVABLE_BATCH_ID OUT NUMBER)

  IS
  BEGIN

       INSERT INTO RECEIVABLE_BATCH
       (RECEIVABLE_BATCH_ID
        ,BATCH_NUMBER
        ,SOURCE_SYSTEM
        ,SOURCE_TYPE
        ,AMOUNT
        ,START_DATE
        ,END_DATE
        ,STATUS
        ,NOTE
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY )
	VALUES
	(RECEIVABLE_BATCH_SEQ.NEXTVAL
	,P_BATCH_NUMBER
	,P_SOURCE_SYSTEM
	,P_SOURCE_TYPE
	,P_AMOUNT
	,NVL(P_START_DATE,SYSDATE)
	,NVL(P_END_DATE,SYSDATE)
	,NVL(P_STATUS,'UNAPPLIED')
	,CASE WHEN P_SOURCE_TYPE = 'VENTEGRA_EMPLOYEE_FEED' THEN
       'Pharmacy Rebate Batch '||P_BATCH_NUMBER||' created on '||to_char(SYSDATE,'MM/DD/YYYY HH:MI:SS')
        WHEN P_SOURCE_TYPE = 'VENTEGRA_INVOICE_FEED' THEN
       'Pharmacy Charges Batch '||P_BATCH_NUMBER||'  created on '||to_char(SYSDATE,'MM/DD/YYYY HH:MI:SS')
        WHEN P_SOURCE_TYPE = 'WELLNESS_REBATE' THEN
       'Wellness Bonus Batch '||P_BATCH_NUMBER||' created on '||to_char(SYSDATE,'MM/DD/YYYY HH:MI:SS')
        WHEN P_SOURCE_TYPE = 'AR_INVOICE' THEN
       'Invoice Batch '||P_BATCH_NUMBER||' created on '||to_char(SYSDATE,'MM/DD/YYYY HH:MI:SS')
   END
	,SYSDATE
	,P_USER_ID
	,SYSDATE
	,P_USER_ID) RETURNING RECEIVABLE_BATCH_ID INTO X_RECEIVABLE_BATCH_ID;
  END INSERT_RECEIVABLE_BATCH;
*/
/*
  PROCEDURE UPDATE_APPLIED_AMOUNT(P_RECEIVABLE_ID  IN NUMBER
                                 ,P_BATCH_NUMBER   IN NUMBER
                                 ,P_AMOUNT_APPLIED IN NUMBER
                                 ,P_NOTE           IN VARCHAR2
                                 ,P_USER_ID        IN NUMBER
                                 ,P_PAYMENT_BATCH_ID IN NUMBER)
  IS
    l_entity_type      varchar2(30) := 'x';
  BEGIN
    IF P_AMOUNT_APPLIED > 0 AND P_RECEIVABLE_ID IS NOT NULL THEN
        UPDATE RECEIVABLE
        SET    STATUS = CASE WHEN AMOUNT = P_AMOUNT_APPLIED THEN 'POSTED'
                             WHEN AMOUNT > P_AMOUNT_APPLIED THEN 'PARTIALLY_POSTED'
                        ELSE STATUS END
           ,   AMOUNT_APPLIED = P_AMOUNT_APPLIED
           ,   APPLIED_DATE   = SYSDATE
           ,   PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID
           ,   NOTE           = P_NOTE
           ,   LAST_UPDATE_DATE = SYSDATE
           ,   LAST_UPDATED_BY = P_USER_ID
        WHERE RECEIVABLE_ID = P_RECEIVABLE_ID;

        l_entity_type := get_receivable_entity_type(P_RECEIVABLE_ID);
        if l_entity_type = 'EMPLOYER' then
            UPDATE employer_deposits
            SET    STATUS = CASE WHEN AMOUNT = P_AMOUNT_APPLIED THEN 'POSTED'
                                 WHEN AMOUNT > P_AMOUNT_APPLIED THEN 'PARTIALLY_POSTED'
                            ELSE STATUS END
               ,   AMOUNT_APPLIED = P_AMOUNT_APPLIED
               ,   APPLIED_DATE   = SYSDATE
               ,   NOTE           = P_NOTE
               ,   LAST_UPDATE_DATE = SYSDATE
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE RECEIVABLE_ID = P_RECEIVABLE_ID;
        end if;

    END IF;

    FOR X IN ( SELECT SUM(AMOUNT_APPLIED) AMOUNT
               FROM   RECEIVABLE
               WHERE  PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID)
    LOOP
        UPDATE RECEIVABLE_PAYMENTS
        SET    STATUS = CASE WHEN AMOUNT-X.AMOUNT = 0 THEN 'POSTED' ELSE 'PARTIALLY_POSTED' END
           ,   POSTED_BALANCE = X.AMOUNT
           ,   REMAINING_BALANCE = (AMOUNT-X.AMOUNT )
           ,   LAST_UPDATE_DATE = SYSDATE
           ,   LAST_UPDATED_BY  = P_USER_ID
        WHERE  PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID;

    END LOOP;

    --Receipt Posting
    FOR X IN ( SELECT ACC_ID
                    , AMOUNT_APPLIED
                    , SOURCE_TYPE
                    , DECODE(SOURCE_TYPE,'VENTEGRA_EMPLOYEE_FEED'
                            ,'PHARMACY_REBATE',SOURCE_TYPE) FEE_CODE
                    , START_DATE
                    , CREATION_DATE
                    , APPLIED_DATE
                    , RECEIVABLE_ID
               FROM  RECEIVABLE
               WHERE RECEIVABLE_ID = P_RECEIVABLE_ID
               and   source_type in('PHARMACY_REBATE','VENTEGRA_EMPLOYEE_FEED','WELLNESS_REBATE'))
    LOOP
        PC_RECEIPT.UPSERT_RECEIPT (p_acc_id  => X.ACC_ID
                         ,p_fee_code         => X.FEE_CODE
		                  	 ,p_receipt_source   => X.SOURCE_TYPE
                         ,p_amount           => X.AMOUNT_APPLIED
                         ,p_transaction_date => X.START_DATE
                         ,p_receipt_date     => X.CREATION_DATE
                         ,p_processed_date   => X.APPLIED_DATE
                         ,p_note             => 'Processed on '||to_char(sysdate,'mm/dd/yyyy')
                         ,p_entity_id        => X.RECEIVABLE_ID
                         ,p_entity_type      => 'RECEIVABLE'
                         ,p_user_id          => P_USER_ID);
     END LOOP;

  END UPDATE_APPLIED_AMOUNT;
  */
    procedure process_invoice_batch (
        p_batch_number in varchar2,
        p_user_id      in number
    ) is
        l_receivable_batch_id number;
    begin

      /** Insert into batch

       FOR X IN ( SELECT SUM(INVOICE_AMOUNT) REBATE_AMT
                   FROM  AR_INVOICE
                   WHERE BATCH_NUMBER = P_BATCH_NUMBER)
       LOOP
               PC_RECEIVABLE.INSERT_RECEIVABLE_BATCH
              (P_BATCH_NUMBER   => P_BATCH_NUMBER
              ,P_SOURCE_SYSTEM => 'STERLING_SIA'
              ,P_SOURCE_TYPE   => 'AR_INVOICE'
              ,P_AMOUNT        => X.REBATE_AMT
              ,P_STATUS        => 'POSTED_TO_INVOICE'
              ,P_START_DATE    => SYSDATE
              ,P_END_DATE     => SYSDATE
              ,P_USER_ID      => p_user_id
              ,X_RECEIVABLE_BATCH_ID => L_RECEIVABLE_BATCH_ID);
       END LOOP;
       */
         /** insert into receivale ***/
        insert into receivable (
            receivable_id,
            group_number,
            member_number,
            acc_id,
            source_system,
            source_type,
            amount,
            start_date,
            end_date,
            status,
            note,
            created_by,
            last_updated_by,
            batch_number,
            invoice_id,
            invoice_date
        )
            select
                receivable_seq.nextval,
                x.acc_num,
                null,
                x.acc_id,
                'STERLING_SIA',
                'AR_INVOICE',
                x.invoice_amount,
                sysdate,
                sysdate,
                'POSTED_TO_INVOICE',
                'Invoice for '
                || x.acc_num
                || ' generated on '
                || to_char(sysdate, 'MM/DD/YYYY'),
                p_user_id,
                p_user_id,
                p_batch_number,
                x.invoice_id,
                x.invoice_date
            from
                ar_invoice x
            where
                batch_number = p_batch_number;

        insert into receivable_details (
            receivable_det_id,
            receivable_id,
            group_acc_id,
            rate_code,
            amount,
            transaction_date,
            group_number,
            quantity,
            line_amount,
            status,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                receivable_details_seq.nextval,
                a.receivable_id,
                a.acc_id -- EMPLOYER'S ACC_ID
                ,
                d.rate_code,
                total_line_amount,
                sysdate,
                b.acc_num,
                d.quantity,
                d.unit_rate_cost,
                'POSTED_TO_INVOICE',
                'Processed from Rebate/Invoice batch ' || b.acc_num,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                receivable       a,
                ar_invoice       b,
                ar_invoice_lines d
            where  --A.RECEIVABLE_BATCH_ID = l_RECEIVABLE_BATCH_ID    AND
                    a.invoice_id = b.invoice_id
                and b.invoice_id = d.invoice_id
                and a.batch_number = p_batch_number;

      /*for x in(select * from receivable where batch_number = p_batch_number) loop
                  PC_RECEIVABLE.INS_ER_DEPOSIT(
                                P_RECEIVABLE_ID => x.RECEIVABLE_ID,
                                P_ACC_ID => x.ACC_ID,
                                P_SOURCE_SYSTEM => x.SOURCE_SYSTEM,
                                P_SOURCE_TYPE => x.SOURCE_TYPE,
                                P_AMOUNT_APPLIED => null,
                                P_AMOUNT => x.AMOUNT,
                                P_RETURNED_AMOUNT => null,
                                P_REMAINING_AMOUNT => null,
                                P_APPLIED_DATE => null,
                                P_ACCOUNTED_DATE => sysdate,
                                P_CANCELLED_DATE => null,
                                P_GL_DATE => null,
                                P_GL_POSTED_DATE => null,
                                P_INVOICE_ID => x.INVOICE_ID,
                                P_STATUS => x.STATUS,
                                P_TRANSACTION_NUMBER => null,
                                P_PAYMENT_METHOD => null,
                                P_REASON_CODE => null,
                                P_USER_ID => P_USER_ID,
                                P_NOTE => null
                              );
      end loop;
      */
     /* only when health asets implemented
      for x in(select ed.deposit_id,ed.status, rd.line_amount, rd.rate_code, rd.quantity,r.receivable_id, rd.receivable_det_id
               from   receivable_details rd, employer_deposits ed, receivable r
               where  rd.receivable_id = ed.receivable_id
               and    rd.receivable_id = r.receivable_id
               and    r.batch_number   = p_batch_number)
      loop
             PC_RECEIVABLE.INS_ER_DEPOSIT_DET(
                            P_DEPOSIT_ID => x.deposit_id,
                            P_STATUS => x.STATUS,
                            P_QUANTITY => x.QUANTITY,
                            P_LINE_AMOUNT => x.LINE_AMOUNT,
                            P_RATE_CODE => x.RATE_CODE,
                            P_USER_ID => p_user_id,
                            P_NOTE => null,
                            p_receivable_id => x.receivable_id,
                            p_receivable_det_id => x.receivable_det_id
                          );
      end loop;
      */

    end process_invoice_batch;
 /*PROCEDURE POST_REBATE_BATCH(P_BATCH_NUMBER   IN NUMBER
                      ,P_USER_ID        IN NUMBER
                      ,P_PAYMENT_BATCH_ID IN NUMBER)
  IS
  BEGIN
    IF P_BATCH_NUMBER  IS NOT NULL THEN
        UPDATE RECEIVABLE
        SET    STATUS           = 'POSTED'
           ,   AMOUNT_APPLIED   = AMOUNT
           ,   APPLIED_DATE     = SYSDATE
           ,   PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID
           ,   NOTE             = 'Processed as batch on '||to_char(sysdate,'mm/dd/yyyy')
           ,   LAST_UPDATE_DATE = SYSDATE
           ,   LAST_UPDATED_BY  = P_USER_ID
        WHERE BATCH_NUMBER      = P_BATCH_NUMBER;

        UPDATE employer_deposits
        SET    STATUS = 'POSTED'
           ,   AMOUNT_APPLIED = AMOUNT
           ,   APPLIED_DATE   = SYSDATE
           ,   NOTE           = 'Processed as batch on '||to_char(sysdate,'mm/dd/yyyy')
           ,   LAST_UPDATE_DATE = SYSDATE
           ,   LAST_UPDATED_BY = P_USER_ID
        WHERE RECEIVABLE_ID in(select receivable_id from RECEIVABLE where batch_number = P_BATCH_NUMBER);
    END IF;

    UPDATE RECEIVABLE_PAYMENTS
    SET    STATUS = 'POSTED'
       ,   POSTED_BALANCE = AMOUNT
       ,   REMAINING_BALANCE = 0
       ,   LAST_UPDATE_DATE = SYSDATE
       ,   LAST_UPDATED_BY  = P_USER_ID
    WHERE  PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID;

    -- Receipt Posting to employees
    FOR X IN ( SELECT ACC_ID
                    , AMOUNT_APPLIED
                    , SOURCE_TYPE
                    , DECODE(SOURCE_TYPE,'VENTEGRA_EMPLOYEE_FEED'
                            ,'PHARMACY_REBATE',SOURCE_TYPE) FEE_CODE
                    , START_DATE
                    , CREATION_DATE
                    , APPLIED_DATE
                    , RECEIVABLE_ID
               FROM  RECEIVABLE
               WHERE PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID
	       AND   BATCH_NUMBER = P_BATCH_NUMBER
               and   source_type in('PHARMACY_REBATE','VENTEGRA_EMPLOYEE_FEED','WELLNESS_REBATE'))
    LOOP
        PC_RECEIPT.UPSERT_RECEIPT (p_acc_id  => X.ACC_ID
                         ,p_fee_code         => X.FEE_CODE
		                   	 ,p_receipt_source   => X.SOURCE_TYPE
                         ,p_amount           => X.AMOUNT_APPLIED
                         ,p_transaction_date => X.START_DATE
                         ,p_receipt_date     => X.CREATION_DATE
                         ,p_processed_date   => X.APPLIED_DATE
                         ,p_note             => 'Processed on '||to_char(sysdate,'mm/dd/yyyy')
                         ,p_entity_id        => X.RECEIVABLE_ID
                         ,p_entity_type      => 'RECEIVABLE'
                         ,p_user_id          => P_USER_ID);

     END LOOP;

     UPDATE_RECV_PAYMENT_BAL(P_PAYMENT_BATCH_ID,P_BATCH_NUMBER);
     -- Update status of batch
     UPDATE_RECEIVABLE_BATCH_STATUS(P_BATCH_NUMBER);
  END POST_REBATE_BATCH;
  */
    procedure update_receivable_status (
        p_receivable_id in number,
        p_status        in varchar2,
        p_note          in varchar2,
        p_user_id       in number
    ) is
        l_entity_type varchar2(30) := 'x';
    begin
        update receivable
        set
            status = p_status,
            note = p_note,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = p_receivable_id;

        update receivable_details
        set
            status = p_status,
            note = p_note,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = p_receivable_id;

       /* l_entity_type := get_receivable_entity_type(P_RECEIVABLE_ID);
        -- only when health assets implemented
        if l_entity_type = 'EMPLOYER' then
                UPDATE employer_deposits
                SET    STATUS = P_STATUS
                   ,   NOTE           = P_NOTE
                   ,   LAST_UPDATE_DATE = SYSDATE
                   ,   LAST_UPDATED_BY = P_USER_ID
                WHERE  RECEIVABLE_ID = P_RECEIVABLE_ID;

                UPDATE employer_deposit_details
                SET    STATUS = P_STATUS
                   ,   NOTE           = P_NOTE
                   ,   LAST_UPDATE_DATE = SYSDATE
                   ,   LAST_UPDATED_BY = P_USER_ID
                WHERE  RECEIVABLE_ID = P_RECEIVABLE_ID;
        end if;
        */
    end update_receivable_status;
 /* PROCEDURE UPDATE_RECEIVABLE_BATCH(P_BATCH_NUMBER IN VARCHAR2
                                   ,P_STATUS       IN VARCHAR2
                                   ,P_USER_ID      IN NUMBER)
  IS
  BEGIN
    UPDATE RECEIVABLE_BATCH
    SET    STATUS = P_STATUS
       ,   LAST_UPDATE_DATE = SYSDATE
       ,   LAST_UPDATED_BY = P_USER_ID
    WHERE  BATCH_NUMBER = P_BATCH_NUMBER;

  END UPDATE_RECEIVABLE_BATCH;
  */
  /*
  PROCEDURE UPDATE_RECV_PAYMENT_BAL(P_PAYMENT_BATCH_ID IN NUMBER,P_BATCH_NUMBER IN NUMBER)
  IS
  BEGIN
      FOR X IN (SELECT SUM(NVL(A.AMOUNT_APPLIED,0)) AMOUNT_APPLIED, B.PAYMENT_BATCH_ID, B.AMOUNT
                  FROM   RECEIVABLE A,RECEIVABLE_PAYMENTS B
                  WHERE A.PAYMENT_BATCH_ID  = B.PAYMENT_BATCH_ID
                  AND   A.BATCH_NUMBER = B.BATCH_NUMBER
                  AND   A.BATCH_NUMBER = P_BATCH_NUMBER
                  AND   A.PAYMENT_BATCH_ID = P_PAYMENT_BATCH_ID
                  AND   A.STATUS = 'POSTED'
                  AND   B.STATUS NOT IN ('CANCELED','CANCELLED','REVERSED')
                  GROUP BY B.PAYMENT_BATCH_ID, B.AMOUNT)
      LOOP
       IF X.AMOUNT_APPLIED >= X.AMOUNT THEN
         UPDATE RECEIVABLE_PAYMENTS
         SET    POSTED_BALANCE = NVL(X.AMOUNT_APPLIED,0)
             ,  REMAINING_BALANCE = X.AMOUNT-NVL(X.AMOUNT_APPLIED,0)
             ,  STATUS = 'POSTED'
             ,  LAST_UPDATE_DATE = SYSDATE
             ,  LAST_UPDATED_BY = 0
         WHERE BATCH_NUMBER = P_BATCH_NUMBER
          AND  PAYMENT_BATCH_ID= P_PAYMENT_BATCH_ID;
       ELSIF X.AMOUNT_APPLIED > 0 AND X.AMOUNT_APPLIED < X.AMOUNT THEN
         UPDATE RECEIVABLE_PAYMENTS
         SET    POSTED_BALANCE = NVL(X.AMOUNT_APPLIED,0)
             ,  REMAINING_BALANCE = X.AMOUNT-NVL(X.AMOUNT_APPLIED,0)
             ,  STATUS = 'PARTIALLY_POSTED'
             ,  LAST_UPDATE_DATE = SYSDATE
             ,  LAST_UPDATED_BY = 0
         WHERE BATCH_NUMBER = P_BATCH_NUMBER
          AND  PAYMENT_BATCH_ID= P_PAYMENT_BATCH_ID;
       END IF;
      END LOOP;
   END UPDATE_RECV_PAYMENT_BAL;
   */
 /* PROCEDURE PROCESS_REBATE_BATCH (P_BATCH_NUMBER IN VARCHAR2
                                 ,P_USER_ID      IN NUMBER)
  IS
   L_RECEIVABLE_BATCH_ID NUMBER;
  BEGIN

        -- Insert into batch

        FOR X IN ( SELECT SUM(REBATE_AMT) REBATE_AMT
                        , MIN(EVENT_DATE) START_DATE
                        , MAX(EVENT_DATE) END_DATE
                        , REBATE_SOURCE
                        , CASE WHEN REBATE_SOURCE LIKE 'VENTEGRA%' THEN
                            'VENTEGRA'
                          WHEN REBATE_SOURCE LIKE 'WELLNESS%' THEN
                             'WELLNESS'
                          END SOURCE_SYSTEM
                     FROM  REBATE_STAGING
                     WHERE BATCH_NUMBER = P_BATCH_NUMBER
                     AND   processed_flag  = 'N'
                     group by REBATE_SOURCE, BATCH_NUMBER)
         LOOP
                       PC_RECEIVABLE.INSERT_RECEIVABLE_BATCH
                       (P_BATCH_NUMBER   => P_BATCH_NUMBER
                        ,P_SOURCE_SYSTEM => X.SOURCE_SYSTEM
                        ,P_SOURCE_TYPE   => x.REBATE_SOURCE
                        ,P_AMOUNT        => X.REBATE_AMT
                        ,P_STATUS        => 'UNAPPLIED'
                        ,P_START_DATE    => x.START_DATE
                         ,P_END_DATE     => x.END_DATE
                         ,P_USER_ID      => p_user_id
                         ,X_RECEIVABLE_BATCH_ID => L_RECEIVABLE_BATCH_ID);
         END LOOP;
         -- insert into receivale
       INSERT INTO RECEIVABLE
      (RECEIVABLE_ID
      ,RECEIVABLE_BATCH_ID
      ,EMPLR_ID
      ,GROUP_NUMBER
      ,MEMBER_NUMBER
      ,ACC_ID
      ,SOURCE_SYSTEM
      ,SOURCE_TYPE
      ,AMOUNT
      ,START_DATE
      ,END_DATE
      ,STATUS
      ,NOTE
      ,CREATED_BY
      ,LAST_UPDATED_BY
      ,BATCH_NUMBER)
      SELECT RECEIVABLE_SEQ.NEXTVAL
           , L_RECEIVABLE_BATCH_ID
           , PC_EMPLR.get_emplr_id(X.GROUP_NUMBER)
           , X.GROUP_NUMBER
           , X.MEMBER_NUMBER
           , X.ACC_ID
           , X.SOURCE_SYSTEM
           , X.REBATE_SOURCE
           , X.AMOUNT
           , X.START_DATE
           , X.END_DATE
           , 'UNAPPLIED'
           , 'Processed from Rebate batch'
           , P_USER_ID
           , P_USER_ID
           , P_BATCH_NUMBER
      FROM  (SELECT BATCH_NUMBER
                   , B.ACC_ID
                   , CASE WHEN REBATE_SOURCE LIKE 'VENTEGRA%' THEN
                          'VENTEGRA'
                        WHEN REBATE_SOURCE LIKE 'WELLNESS%' THEN
                           'WELLNESS'
                        END SOURCE_SYSTEM
                   , REBATE_SOURCE
                   , A.GROUP_NUMBER
                   , A.MEMBER_NUMBER
                   , SUM(REBATE_AMT) AMOUNT
                   , MIN(EVENT_DATE) START_DATE
                   , MAX(EVENT_DATE) END_DATE
              FROM  REBATE_STAGING A, ACCOUNT B
              WHERE A.BATCH_NUMBER= P_BATCH_NUMBER
              AND   B.DEPENDENT_ID IS NULL
              AND   processed_flag  = 'N'
              AND   A.GROUP_NUMBER = B.ACC_NUM
              AND   REBATE_ENTITY = 'EMPLOYER'
              group by BATCH_NUMBER, B.ACC_ID, CASE WHEN REBATE_SOURCE LIKE 'VENTEGRA%' THEN
                          'VENTEGRA'
                        WHEN REBATE_SOURCE LIKE 'WELLNESS%' THEN
                           'WELLNESS'
                        END, REBATE_SOURCE, A.GROUP_NUMBER, A.MEMBER_NUMBER
              UNION
              SELECT BATCH_NUMBER
                   , B.ACC_ID
                   , CASE WHEN REBATE_SOURCE LIKE 'VENTEGRA%' THEN
                          'VENTEGRA'
                        WHEN REBATE_SOURCE LIKE 'WELLNESS%' THEN
                           'WELLNESS'
                        END SOURCE_SYSTEM
                   , REBATE_SOURCE
                   , A.GROUP_NUMBER
                   , nvl(A.MEMBER_NUMBER,PC_ACCOUNT.get_acc_num_from_ssn(A.SSN))
                   , SUM(REBATE_AMT) AMOUNT
                   , MIN(EVENT_DATE) START_DATE
                   , MAX(EVENT_DATE) END_DATE
              FROM  REBATE_STAGING A, ACCOUNT B
              WHERE A.BATCH_NUMBER= P_BATCH_NUMBER
              AND   B.DEPENDENT_ID IS NULL
              AND   processed_flag  = 'N'
              AND  ( A.MEMBER_NUMBER IS NOT NULL AND A.MEMBER_NUMBER = B.ACC_NUM
                OR   A.SSN IS NOT NULL AND B.ACC_NUM= PC_ACCOUNT.get_acc_num_from_ssn(A.SSN))
              AND   REBATE_ENTITY = 'MEMBER'
              GROUP BY B.ACC_ID, BATCH_NUMBER, REBATE_SOURCE, A.GROUP_NUMBER
                   , A.MEMBER_NUMBER,A.SSN   ) x;

      INSERT INTO RECEIVABLE_DETAILS
      (RECEIVABLE_DET_ID
      ,RECEIVABLE_ID
      ,GROUP_ACC_ID
      ,ACC_ID
      ,AMOUNT
      ,TRANSACTION_DATE
      ,GROUP_NUMBER
      ,MEMBER_NUMBER
      ,QUANTITY
      ,LINE_AMOUNT
      ,STATUS
      ,NOTE
      ,RATE_CODE
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY )
      SELECT RECEIVABLE_DETAIL_SEQ.NEXTVAL
           , A.RECEIVABLE_ID
           , pc_account.GET_ACC_ID(C.GROUP_NUMBER) -- CHECK
           , A.ACC_ID -- CHECK
           , C.REBATE_AMT
           , NVL(C.EVENT_DATE,SYSDATE)
           , A.GROUP_NUMBER
           , A.MEMBER_NUMBER
      	   , NVL(C.NO_OF_UNITS,1)
	         , NVL(C.UNIT_PRICE,C.REBATE_AMT)
           , 'UNAPPLIED'
           , 'Processed from Rebate/Invoice batch'
           , CASE WHEN C.REBATE_SOURCE = 'WELLNESS_REBATE' THEN
                   'WELLNESS_REBATE'
                  WHEN C.REBATE_SOURCE = 'VENTEGRA_EMPLOYEE_FEED' THEN
                   'PHARMACY_REBATE'
                  WHEN C.REBATE_SOURCE = 'VENTEGRA_INVOICE_FEED' THEN
                   'PHARMACY_CHARGE'
             END
           , SYSDATE
           , P_USER_ID
           , SYSDATE
           , P_USER_ID
      FROM   RECEIVABLE A
           , REBATE_STAGING C
      WHERE  A.RECEIVABLE_BATCH_ID = l_RECEIVABLE_BATCH_ID
      AND   processed_flag  = 'N'
      AND    A.BATCH_NUMBER = C.BATCH_NUMBER
      AND    A.GROUP_NUMBER = C.GROUP_NUMBER
      AND    NVL(A.MEMBER_NUMBER,'-1')= NVL(C.MEMBER_NUMBER,'-1')
      AND    C.BATCH_NUMBER= P_BATCH_NUMBER;

      UPDATE REBATE_STAGING
      SET    PROCESSED_FLAG = 'Y'
         ,   PROCESSED_DATE = SYSDATE
         ,   LAST_UPDATE_DATE = SYSDATE
         ,   LAST_UPDATED_BY = P_USER_ID
      WHERE  BATCH_NUMBER = P_BATCH_NUMBER
      AND    PROCESSED_FLAG = 'N';

  END PROCESS_REBATE_BATCH;
  */

    procedure insert_receivable_payments (
        p_receivable_id    in number,
        p_check_number     in number,
        p_acc_id           in number,
        p_amount           in number,
        p_start_date       in date,
        p_end_date         in date,
        p_invoice_id       in number,
        p_txn_number       in varchar2,
        p_txn_date         in date,
        p_txn_type         in varchar2,
        p_txn_source       in varchar2,
        p_note             in varchar2,
        p_status           in varchar2,
        p_user_id          in number,
        p_payment_batch_id in number,
        p_batch_number     in varchar2,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is
    begin
        x_return_status := 'S';
        insert into employer_payments (
            employer_payment_id
      --  ,receivable_id
            ,
            entrp_id,
            check_amount,
            check_number,
            check_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            bank_acct_id,
            payment_register_id,
            list_bill,
            reason_code,
            transaction_date,
            plan_type,
            pay_code,
            invoice_id
        ) values ( employer_payments_seq.nextval
      --  ,p_receivable_id
        ,
                   (
                       select
                           entrp_id
                       from
                           account
                       where
                           acc_id = p_acc_id
                   ),
                   p_amount,
                   p_check_number,
                   sysdate,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   p_note,
                   null,
                   p_payment_batch_id,
                   null,
                   2,
                   null,
                   null,
                   null,
                   p_invoice_id );

    --revise
/*	INSERT INTO RECEIVABLE_PAYMENTS
	(RECV_PAYMENT_ID
	,RECEIVABLE_ID
	,ACC_ID
	,AMOUNT
	,START_DATE
	,END_DATE
	,INVOICE_ID
	,TRANSACTION_NUMBER
	,TRANSACTION_DATE
	,TRANSACTION_TYPE
        ,TRANSACTION_SOURCE
	,STATUS
	,NOTE
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,PAYMENT_BATCH_ID
	,BATCH_NUMBER)
	VALUES
	(RECV_PAYMENT_SEQ.NEXTVAL
	,P_RECEIVABLE_ID
	,P_ACC_ID
	,P_AMOUNT
	,P_START_DATE
	,P_END_DATE
	,P_INVOICE_ID
	,P_TXN_NUMBER
	,P_TXN_DATE
	,P_TXN_TYPE
        ,P_TXN_SOURCE
	,P_STATUS
	,P_NOTE
	,SYSDATE
	,P_USER_ID
	,SYSDATE
	,P_USER_ID
	,P_PAYMENT_BATCH_ID
	,P_BATCH_NUMBER);
 */

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_receivable_payments;

    procedure post_checks (
        p_batch_number     in varchar2,
        p_txn_number       in varchar2,
        p_txn_date         in date,
        p_txn_type         in varchar2,
        p_amount           in number,
        p_acc_id           in number,
        p_invoice_id       in number,
        p_note             in varchar2,
        p_status           in varchar2,
        p_receivable_id    in number,
        p_source           in varchar2,
        p_user_id          in number,
        x_payment_batch_id out number
    ) is

        l_payment_batch_id number;
        l_return_status    varchar2(1) := 'S';
        l_error_message    varchar2(3200);
        l_exists           varchar2(1) := 'N';
    begin
 /*
  IF P_INVOICE_ID IS  NULL THEN
      FOR X IN ( SELECT RECV_PAYMENT_ID,PAYMENT_BATCH_ID
                 FROM  RECEIVABLE_PAYMENTS
		            WHERE  BATCH_NUMBER = P_BATCH_NUMBER
		            AND    TRANSACTION_NUMBER = P_TXN_NUMBER)
       LOOP
           UPDATE RECEIVABLE_PAYMENTS
	           SET   AMOUNT = NVL(P_AMOUNT,AMOUNT)
  	             ,  NOTE = NOTE ||' updated on '||TO_CHAR(SYSDATE,'MM/DD/YYYY')
               ,  LAST_UPDATE_DATE  = SYSDATE
               ,  LAST_UPDATED_BY   = p_user_id
	        WHERE  RECV_PAYMENT_ID = X.RECV_PAYMENT_ID;
          X_PAYMENT_BATCH_ID := X.PAYMENT_BATCH_ID;
	       l_exists := 'Y';
      END LOOP;
   ELSE
        FOR X IN ( SELECT RECV_PAYMENT_ID,PAYMENT_BATCH_ID
                 FROM  RECEIVABLE_PAYMENTS
		            WHERE  INVOICE_ID = P_INVOICE_ID)
       LOOP
          X_PAYMENT_BATCH_ID := X.PAYMENT_BATCH_ID;
       END LOOP;
   END IF;
   IF   l_exists <> 'Y' THEN
        IF X_PAYMENT_BATCH_ID IS NULL THEN
          SELECT PAYMENT_BATCH_SEQ.NEXTVAL INTO X_PAYMENT_BATCH_ID FROM DUAL;
        END IF;

          INSERT_RECEIVABLE_PAYMENTS
          (P_RECEIVABLE_ID => P_RECEIVABLE_ID
          ,p_check_number  => null  --revise required??
          ,P_ACC_ID        => P_ACC_ID
          ,P_AMOUNT        => P_AMOUNT
          ,P_START_DATE    => NULL
          ,P_END_DATE      => NULL
          ,P_INVOICE_ID    => P_INVOICE_ID
          ,P_TXN_NUMBER    => P_TXN_NUMBER
          ,P_TXN_DATE      => P_TXN_DATE
          ,P_TXN_TYPE      => P_TXN_TYPE
          ,P_TXN_SOURCE    => P_SOURCE
          ,P_NOTE          => P_NOTE
          ,P_STATUS        => P_STATUS
          ,P_USER_ID       => P_USER_ID
          ,P_PAYMENT_BATCH_ID => X_PAYMENT_BATCH_ID
          ,P_BATCH_NUMBER  => P_BATCH_NUMBER
          ,X_RETURN_STATUS => L_RETURN_STATUS
          ,X_ERROR_MESSAGE => L_ERROR_MESSAGE);
      END IF;

*/
        null;
    end post_checks;

 /*
 PROCEDURE UPDATE_RECEIVABLE_BATCH_STATUS(P_BATCH_NUMBER IN VARCHAR2)
 IS
   l_count NUMBER;
   l_status VARCHAR2(30);
 BEGIN

    SELECT COUNT(*)
    INTO   l_count
    FROM  RECEIVABLE WHERE BATCH_NUMBER = P_BATCH_NUMBER;

    FOR X IN ( SELECT COUNT(*) cnt , STATUS
                FROM  RECEIVABLE WHERE BATCH_NUMBER = P_BATCH_NUMBER
                GROUP BY STATUS)
    LOOP
       IF X.STATUS = 'UNAPPLIED' AND X.cnt > 0 AND l_count <> X.cnt THEN
          l_status := 'PARTIALLY_POSTED';
       END IF;
       IF X.STATUS <> 'UNAPPLIED' AND X.cnt = l_count THEN
          l_status := X.STATUS;
       END IF;
    END LOOP;
    UPDATE RECEIVABLE_BATCH
    SET    STATUS = NVL(L_STATUS,STATUS)
    WHERE  BATCH_NUMBER = P_BATCH_NUMBER;
 END UPDATE_RECEIVABLE_BATCH_STATUS;
 */

    procedure cancel_receivable (
        p_receivable_id in number,
        p_status        in varchar2,
        p_reason        in varchar2,
        p_user_id       in number
    ) is

        l_payment_batch_id number;
        l_amount           number;
        l_return_status    varchar2(1) := 'S';
        l_error_message    varchar2(3200);
        l_exists           varchar2(1) := 'N';
        l_entity_type      varchar2(30) := 'x';
    begin
        update receivable
        set
            status = p_status,
            last_update_date = sysdate,
            cancelled_date = decode(p_status, 'CANCELLED', sysdate, null),
            cancel_reason = decode(p_status, 'CANCELLED', p_reason, null),
            cancelled_by = decode(p_status, 'CANCELLED', p_user_id, null),
            last_updated_by = p_user_id
        where
            receivable_id = p_receivable_id
        returning payment_batch_id into l_payment_batch_id;

        update receivable_details
        set
            status = p_status,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = p_receivable_id;

        l_entity_type := get_receivable_entity_type(p_receivable_id);
   /*  only when health asset implemented
   if l_entity_type = 'EMPLOYER' then
           UPDATE employer_deposits
            SET    STATUS = P_STATUS
               ,   LAST_UPDATE_DATE =  SYSDATE
               ,   CANCELLED_DATE = DECODE(P_STATUS,'CANCELLED',SYSDATE,NULL)
               ,   REASON_CODE  = DECODE(P_STATUS,'CANCELLED',P_REASON,NULL)
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE RECEIVABLE_ID = P_RECEIVABLE_ID;
            update employer_deposit_details
            SET    STATUS = P_STATUS
               ,   LAST_UPDATE_DATE =  SYSDATE
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE  receivable_id= P_RECEIVABLE_ID;
    end if;
  */
/*  revise with vanitha
       -- If a receivable line is cancelled , then reverse the payment for that line
       -- increase the remaining balance in receivable payments if the status was 'POSTED'
       -- if it is POST_TO_INVOICE do nothing
    IF P_STATUS = 'CANCELLED' THEN
        SELECT  SUM(NVL(AMOUNT,0))
	       INTO  L_AMOUNT
         FROM   RECEIVABLE
	       WHERE  BATCH_NUMBER = P_BATCH_NUMBER
	       AND    PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID
	       AND    STATUS = 'CANCELLED';

          UPDATE RECEIVABLE_PAYMENTS
	          SET   POSTED_BALANCE = GREATEST(0,POSTED_BALANCE-NVL(L_AMOUNT,0)) -- if nothing posted, we dont want to make it negative
	                                                                        -- so just default to zero if nothing posted
              ,  REMAINING_BALANCE = LEAST(AMOUNT,NVL(REMAINING_BALANCE,0)+NVL(L_AMOUNT,0))
		                                                                -- if nothing posted, we dont want to make
										-- it to go over the check amount
	                                                                        -- so just default to transaction amount if nothing posted
  	          ,  NOTE = NOTE ||' updated on '||TO_CHAR(SYSDATE,'MM/DD/YYYY')
              ,  LAST_UPDATE_DATE  = SYSDATE
              ,  LAST_UPDATED_BY   = p_user_id
         WHERE  PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID;

     END IF;
     */
    end cancel_receivable;

    procedure cancel_receivable_line (
        p_receivable_line_id in number,
        p_status             in varchar2,
        p_amount             in number,
        p_reason             in varchar2,
        p_user_id            in number
    ) is
        l_receivable_id number;
        l_entity_type   varchar2(30) := 'x';
    begin
        update receivable_details
        set
            status = p_status,
            cancelled_amount = p_amount,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_det_id = p_receivable_line_id
        returning receivable_id into l_receivable_id;

        update receivable
        set
            cancelled_amount = ( nvl(cancelled_amount, 0) + p_amount ),
            remaining_amount = calc_remaining_amt(amount,
                                                  (nvl(returned_amount, 0) + p_amount),
                                                  cancelled_amount),
            note = 'receivalbe line '
                   || p_receivable_line_id
                   || ' cancelled ',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = l_receivable_id;

        l_entity_type := get_receivable_entity_type(l_receivable_id);
    /*
    if l_entity_type = 'EMPLOYER' then
            update employer_deposit_details
            SET    STATUS = P_STATUS
               ,   cancelled_amount =  p_amount
               ,   LAST_UPDATE_DATE =  SYSDATE
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE receivable_det_id = p_receivable_line_id;
            UPDATE employer_deposits
            SET    cancelled_amount = (nvl(cancelled_amount,0) + p_amount)
            ,remaining_amount = calc_remaining_amt(amount,(nvl(returned_amount,0)+p_amount),cancelled_amount)
           ,note   ='receivalbe line '||p_receivable_line_id||' cancelled '
           ,LAST_UPDATE_DATE =  SYSDATE
           ,LAST_UPDATED_BY = P_USER_ID
           WHERE RECEIVABLE_ID = l_receivable_id;
     end if;
     */
    end cancel_receivable_line;

    procedure reverse_receivable_line (
        p_receivable_line_id in number,
        p_status             in varchar2,
        p_amount             in number,
        p_reason             in varchar2,
        p_user_id            in number,
        p_pay_method         in varchar2,
        p_pay_source         in varchar2,
        p_txn_type           in varchar2,
        p_txn_number         in number,
        x_payable_id         out number,
        x_error_message      out varchar2,
        x_return_status      out varchar2
    ) is

        l_receivable_id     number;
        l_entity_type       varchar2(30) := 'x';
        l_acc_id            number;
        l_acc_num           varchar2(20);
        l_receivable_status varchar2(50);
        l_app_exception exception;
        l_err_msg           varchar2(250);
    begin
        x_return_status := 'S';
        select
            status
        into l_receivable_status
        from
            receivable r
        where
            receivable_id in (
                select
                    receivable_id
                from
                    receivable_details rd
                where
                    rd.receivable_det_id = p_receivable_line_id
            );

        if l_receivable_status != 'POSTED' then -- fully paid
            l_err_msg := 'Cannot reverse until fully paid';
            raise l_app_exception;
        end if;
        update receivable_details
        set
            status = p_status,
            returned_amount = p_amount,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_det_id = p_receivable_line_id
        returning receivable_id into l_receivable_id;

        update receivable
        set
            remaining_amount = calc_remaining_amt(amount,
                                                  (nvl(returned_amount, 0) + p_amount),
                                                  cancelled_amount),
            returned_amount = nvl(returned_amount, 0) + p_amount,
            note = 'receivalbe line '
                   || p_receivable_line_id
                   || ' reversed ',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = l_receivable_id;

    /*l_entity_type := get_receivable_entity_type(l_receivable_id);

    if l_entity_type = 'EMPLOYER' then
            update employer_deposit_details
            SET    STATUS = P_STATUS
               ,   returned_amount = p_amount
               ,   LAST_UPDATE_DATE =  SYSDATE
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE receivable_det_id = p_receivable_line_id;
            UPDATE employer_deposits
            SET    remaining_amount = calc_remaining_amt(amount,(nvl(returned_amount,0)+p_amount),cancelled_amount)
           ,returned_amount  = nvl(returned_amount,0)+p_amount
           ,note   ='receivalbe line '||p_receivable_line_id||' reversed '
           ,LAST_UPDATE_DATE =  SYSDATE
           ,LAST_UPDATED_BY = P_USER_ID
           WHERE RECEIVABLE_ID = l_receivable_id;
     end if;
     */
    /* select a.acc_id, a.acc_num into l_acc_id, l_acc_num
     from   account a, receivable r
     where  a.acc_id = r.acc_id
     and    r.receivable_id = l_receivable_id;

     PC_PAYABLE.CREATE_ER_PAYOUT(
                    P_ACC_NUM       => l_acc_num,
                    P_ACC_ID        => l_acc_id,
                    P_PAY_METHOD    => P_PAY_METHOD,
                    P_PAY_SOURCE    => P_PAY_SOURCE,
                    P_TXN_TYPE      => P_TXN_TYPE,
                    P_TXN_NUMBER    => P_TXN_NUMBER,
                    P_REQUEST_DATE  => sysdate,
                    P_REQUEST_AMOUNT => p_amount,
                    P_MEMO           => null,
                    P_NOTE           => 'Employer deposit reversal',
                    P_USER_ID        => P_USER_ID,
                    X_PAYABLE_ID     => X_PAYABLE_ID,
                    X_ERROR_MESSAGE  => X_ERROR_MESSAGE,
                    X_RETURN_STATUS  => X_RETURN_STATUS
                  );
    */
    exception
        when others then
            x_return_status := 'E';
            x_error_message := nvl(l_err_msg,
                                   substr(sqlerrm, 1, 150));
    end reverse_receivable_line;

    procedure reverse_receivable (
        p_receivable_id in number,
        p_status        in varchar2,
        p_user_id       in number,
        p_pay_method    in varchar2,
        p_pay_source    in varchar2,
        p_txn_type      in varchar2,
        p_txn_number    in number,
        x_payable_id    out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_payment_batch_id  number;
        l_amount            number;
        l_return_status     varchar2(1) := 'S';
        l_error_message     varchar2(3200);
        l_exists            varchar2(1) := 'N';
        l_entity_type       varchar2(30) := 'x';
        l_acc_id            number;
        l_acc_num           varchar2(20);
        l_app_exception exception;
        l_err_msg           varchar2(250);
        l_receivable_status varchar2(50);
    begin
        x_return_status := 'S';
        select
            status
        into l_receivable_status
        from
            receivable r
        where
            receivable_id = p_receivable_id;

        if l_receivable_status != 'POSTED' then -- fully paid
            l_err_msg := 'Cannot reverse until fully paid';
            raise l_app_exception;
        end if;
        update receivable
        set
            status = p_status,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = p_receivable_id
        returning payment_batch_id into l_payment_batch_id;

        update receivable_details
        set
            status = p_status,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            receivable_id = p_receivable_id;

        l_entity_type := get_receivable_entity_type(p_receivable_id);
    /*
    if l_entity_type = 'EMPLOYER' then
           UPDATE employer_deposit
            SET    STATUS = P_STATUS
               ,   LAST_UPDATE_DATE =  SYSDATE
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE RECEIVABLE_ID = P_RECEIVABLE_ID;
            update employer_deposit_details
            SET    STATUS = P_STATUS
               ,   LAST_UPDATE_DATE =  SYSDATE
               ,   LAST_UPDATED_BY = P_USER_ID
            WHERE  receivable_id= P_RECEIVABLE_ID;
    end if;
    */
   /*  select a.acc_id, a.acc_num,(r.amount - nvl(r.returned_amount,0)) into l_acc_id, l_acc_num,l_amount
     from   account a, receivable r
     where  a.acc_id = r.acc_id
     and    r.receivable_id = p_receivable_id;

    PC_PAYABLE.CREATE_ER_PAYOUT(
                    P_ACC_NUM       => l_acc_num,
                    P_ACC_ID        => l_acc_id,
                    P_PAY_METHOD    => P_PAY_METHOD,
                    P_PAY_SOURCE    => P_PAY_SOURCE,
                    P_TXN_TYPE      => P_TXN_TYPE,
                    P_TXN_NUMBER    => P_TXN_NUMBER,
                    P_REQUEST_DATE  => sysdate,
                    P_REQUEST_AMOUNT => l_amount,
                    P_MEMO           => null,
                    P_NOTE           => 'Employer deposit reversal',
                    P_USER_ID        => P_USER_ID,
                    X_PAYABLE_ID     => X_PAYABLE_ID,
                    X_ERROR_MESSAGE  => X_ERROR_MESSAGE,
                    X_RETURN_STATUS  => X_RETURN_STATUS
                  );
*/
/*
       -- If a receivable line is cancelled , then reverse the payment for that line
       -- increase the remaining balance in receivable payments if the status was 'POSTED'
       -- if it is POST_TO_INVOICE do nothing
    IF P_STATUS = 'REVERSED' THEN
        SELECT  SUM(NVL(AMOUNT,0))
	       INTO  L_AMOUNT
         FROM   RECEIVABLE
	       WHERE  BATCH_NUMBER = P_BATCH_NUMBER
	       AND    PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID
	       AND    STATUS = 'REVERSED';

          UPDATE RECEIVABLE_PAYMENTS
	          SET   POSTED_BALANCE = GREATEST(0,POSTED_BALANCE-NVL(L_AMOUNT,0)) -- if nothing posted, we dont want to make it negative
	                                                                        -- so just default to zero if nothing posted
              ,  REMAINING_BALANCE = LEAST(AMOUNT,NVL(REMAINING_BALANCE,0)+NVL(L_AMOUNT,0))
		                                                                -- if nothing posted, we dont want to make
										-- it to go over the check amount
	                                                                        -- so just default to transaction amount if nothing posted
  	          ,  NOTE = NOTE ||' updated on '||TO_CHAR(SYSDATE,'MM/DD/YYYY')
              ,  LAST_UPDATE_DATE  = SYSDATE
              ,  LAST_UPDATED_BY   = p_user_id
         WHERE  PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID;

        PC_RECEIPT.REVERSE_RECEIPT (
	                  p_entity_id        => P_RECEIVABLE_ID
                         ,p_entity_type      => 'RECEIVABLE'
                         ,p_user_id          => P_USER_ID);

     END IF;
     */
    exception
        when others then
            x_return_status := 'E';
            x_error_message := nvl(l_err_msg,
                                   substr(sqlerrm, 1, 150));
    end reverse_receivable;

/*
PROCEDURE CANCEL_RECEIVABLE_LINE
          (P_BATCH_NUMBER  IN NUMBER
	        ,P_RECEIVABLE_ID IN NUMBER
          ,P_STATUS        IN VARCHAR2
	        ,P_REASON        IN VARCHAR2
          ,P_USER_ID       IN NUMBER)
 IS
    L_PAYMENT_BATCH_ID NUMBER;
    L_AMOUNT           NUMBER;
    L_RETURN_STATUS    VARCHAR2(1) := 'S';
    L_ERROR_MESSAGE    VARCHAR2(3200);
    l_exists           VARCHAR2(1) := 'N';
 BEGIN

    UPDATE RECEIVABLE
    SET    STATUS = P_STATUS
       ,   LAST_UPDATE_DATE =  SYSDATE
       ,   CANCELLED_DATE = DECODE(P_STATUS,'CANCELLED',SYSDATE,NULL)
       ,   CANCEL_REASON  = DECODE(P_STATUS,'CANCELLED',P_REASON,NULL)
       ,   CANCELLED_BY    = DECODE(P_STATUS,'CANCELLED',P_USER_ID,NULL)
       ,   LAST_UPDATED_BY = P_USER_ID
    WHERE RECEIVABLE_ID = P_RECEIVABLE_ID
    RETURNING PAYMENT_BATCH_ID INTO L_PAYMENT_BATCH_ID;

   UPDATE employer_deposit
    SET    STATUS = P_STATUS
       ,   LAST_UPDATE_DATE =  SYSDATE
       ,   CANCELLED_DATE = DECODE(P_STATUS,'CANCELLED',SYSDATE,NULL)
       --,   CANCEL_REASON  = DECODE(P_STATUS,'CANCELLED',P_REASON,NULL)
       --,   CANCELLED_BY    = DECODE(P_STATUS,'CANCELLED',P_USER_ID,NULL)
       ,   LAST_UPDATED_BY = P_USER_ID
    WHERE RECEIVABLE_ID in(select receivable_id from receivable where batch_number= P_RECEIVABLE_ID);
   -- revise should the details be cancelled too?

       -- If a receivable line is cancelled , then reverse the payment for that line
       -- increase the remaining balance in receivable payments if the status was 'POSTED'
       -- if it is POST_TO_INVOICE do nothing
    IF P_STATUS = 'CANCELLED' THEN
        SELECT  SUM(NVL(AMOUNT,0))
	       INTO  L_AMOUNT
         FROM   RECEIVABLE
	       WHERE  BATCH_NUMBER = P_BATCH_NUMBER
	       AND    PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID
	       AND    STATUS = 'CANCELLED';

          UPDATE RECEIVABLE_PAYMENTS
	          SET   POSTED_BALANCE = GREATEST(0,POSTED_BALANCE-NVL(L_AMOUNT,0)) -- if nothing posted, we dont want to make it negative
	                                                                        -- so just default to zero if nothing posted
              ,  REMAINING_BALANCE = LEAST(AMOUNT,NVL(REMAINING_BALANCE,0)+NVL(L_AMOUNT,0))
		                                                                -- if nothing posted, we dont want to make
										-- it to go over the check amount
	                                                                        -- so just default to transaction amount if nothing posted
  	          ,  NOTE = NOTE ||' updated on '||TO_CHAR(SYSDATE,'MM/DD/YYYY')
              ,  LAST_UPDATE_DATE  = SYSDATE
              ,  LAST_UPDATED_BY   = p_user_id
         WHERE  PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID;

     END IF;
 END CANCEL_RECEIVABLE_LINE;
*/
/*
PROCEDURE REVERSE_RECEIVABLE_LINE
          (P_BATCH_NUMBER  IN NUMBER
	        ,P_RECEIVABLE_ID IN NUMBER
          ,P_STATUS        IN VARCHAR2
          ,P_USER_ID       IN NUMBER)
 IS
    L_PAYMENT_BATCH_ID NUMBER;
    L_AMOUNT           NUMBER;
    L_RETURN_STATUS    VARCHAR2(1) := 'S';
    L_ERROR_MESSAGE    VARCHAR2(3200);
    l_exists           VARCHAR2(1) := 'N';
 BEGIN

    UPDATE RECEIVABLE
    SET    STATUS = P_STATUS
       ,   LAST_UPDATE_DATE =  SYSDATE
       ,   LAST_UPDATED_BY = P_USER_ID
    WHERE RECEIVABLE_ID = P_RECEIVABLE_ID
    RETURNING PAYMENT_BATCH_ID INTO L_PAYMENT_BATCH_ID;

    UPDATE employer_deposit
    SET    STATUS = P_STATUS
       ,   LAST_UPDATE_DATE =  SYSDATE
       ,   LAST_UPDATED_BY = P_USER_ID
    WHERE RECEIVABLE_ID =  P_RECEIVABLE_ID   ;
    --revise if this is right?

       -- If a receivable line is cancelled , then reverse the payment for that line
       -- increase the remaining balance in receivable payments if the status was 'POSTED'
       -- if it is POST_TO_INVOICE do nothing
    IF P_STATUS = 'REVERSED' THEN
        SELECT  SUM(NVL(AMOUNT,0))
	       INTO  L_AMOUNT
         FROM   RECEIVABLE
	       WHERE  BATCH_NUMBER = P_BATCH_NUMBER
	       AND    PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID
	       AND    STATUS = 'REVERSED';

          UPDATE RECEIVABLE_PAYMENTS
	          SET   POSTED_BALANCE = GREATEST(0,POSTED_BALANCE-NVL(L_AMOUNT,0)) -- if nothing posted, we dont want to make it negative
	                                                                        -- so just default to zero if nothing posted
              ,  REMAINING_BALANCE = LEAST(AMOUNT,NVL(REMAINING_BALANCE,0)+NVL(L_AMOUNT,0))
		                                                                -- if nothing posted, we dont want to make
										-- it to go over the check amount
	                                                                        -- so just default to transaction amount if nothing posted
  	          ,  NOTE = NOTE ||' updated on '||TO_CHAR(SYSDATE,'MM/DD/YYYY')
              ,  LAST_UPDATE_DATE  = SYSDATE
              ,  LAST_UPDATED_BY   = p_user_id
         WHERE  PAYMENT_BATCH_ID = L_PAYMENT_BATCH_ID;

        PC_RECEIPT.REVERSE_RECEIPT (
	                  p_entity_id        => P_RECEIVABLE_ID
                         ,p_entity_type      => 'RECEIVABLE'
                         ,p_user_id          => P_USER_ID);

     END IF;
 END REVERSE_RECEIVABLE_LINE;
*/
/*
 Procedure ins_er_deposit(  P_RECEIVABLE_ID                           NUMBER
                            ,P_ACC_ID                                  NUMBER
                            ,P_SOURCE_SYSTEM                           VARCHAR2
                            ,P_SOURCE_TYPE                             VARCHAR2
                            ,P_AMOUNT_APPLIED                          NUMBER
                            ,P_AMOUNT                                  NUMBER
                            ,P_RETURNED_AMOUNT                         NUMBER
                            ,P_REMAINING_AMOUNT                        NUMBER
                            ,P_APPLIED_DATE                            DATE
                            ,P_ACCOUNTED_DATE                          DATE
                            ,P_CANCELLED_DATE                          DATE
                            ,P_GL_DATE                                 DATE
                            ,P_GL_POSTED_DATE                          DATE
                            ,P_INVOICE_ID                              NUMBER
                            ,P_STATUS                                  VARCHAR2
                            ,P_TRANSACTION_NUMBER                      NUMBER
                            ,P_PAYMENT_METHOD                          VARCHAR2
                            ,P_REASON_CODE                             VARCHAR2
                            ,P_USER_ID                              NUMBER
                            ,P_NOTE                                    VARCHAR2) is
 begin
   insert into employer_deposits(deposit_id
                ,RECEIVABLE_ID
                ,entrp_ID
                --,SOURCE_SYSTEM
                --,SOURCE_TYPE
                --,AMOUNT_APPLIED
                ,check_AMOUNT
                ,refund_amount
                ,remaining_balance
               -- ,APPLIED_DATE
                --,ACCOUNTED_DATE
               -- ,CANCELLED_DATE
                --,GL_DATE
                --,GL_POSTED_DATE
                --,INVOICE_ID
                --,STATUS
                --,transaction_number
                --,payment_method
                ,reason_code
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,NOTE)
        values( er_deposit_seq.nextval
                ,P_RECEIVABLE_ID
                ,(select entrp_id from account where acc_id=P_ACC_ID)
                --,P_SOURCE_SYSTEM
                --,P_SOURCE_TYPE
                --,nvl(P_AMOUNT_APPLIED,0)
                ,nvl(P_AMOUNT,0)
                ,nvl(P_returned_amount,0)
                ,nvl(P_remaining_amount,0)
               -- ,P_APPLIED_DATE
                --,P_ACCOUNTED_DATE
                --,P_CANCELLED_DATE
                --,P_GL_DATE
                --,P_GL_POSTED_DATE
                --,P_INVOICE_ID
                --,P_STATUS
                --,P_transaction_number
                --,P_payment_method
                ,P_reason_code
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,P_NOTE);

 end ins_er_deposit;
 */
    procedure ins_er_deposit_det (
        p_deposit_id        number,
        p_status            varchar2,
        p_quantity          number,
        p_line_amount       number,
        p_rate_code         varchar2,
        p_user_id           number,
        p_note              varchar2,
        p_receivable_id     number,
        p_receivable_det_id number
    ) as
    begin
  /*  insert into employer_deposit_details(DEPOSIT_DET_ID
                                        ,DEPOSIT_ID
                                        ,STATUS
                                        ,QUANTITY
                                        ,LINE_AMOUNT
                                        ,RATE_CODE
                                        ,CREATION_DATE
                                        ,CREATED_BY
                                        ,LAST_UPDATE_DATE
                                        ,LAST_UPDATED_BY
                                        ,NOTE
                                        ,receivable_id
                                        ,receivable_det_id)
                        values(er_deposit_det_seq.nextval
                                ,P_DEPOSIT_ID
                                ,P_STATUS
                                ,P_QUANTITY
                                ,P_LINE_AMOUNT
                                ,P_RATE_CODE
                                ,sysdate
                                ,P_USER_ID
                                ,sysdate
                                ,P_USER_ID
                                ,P_NOTE
                                ,p_receivable_id
                                ,p_receivable_det_id );*/
        null;
    end ins_er_deposit_det;
 /*
 PROCEDURE UPDATE_ER_DEPOSIT_STATUS(P_RECEIVABLE_ID  IN NUMBER
                                 ,P_STATUS            IN VARCHAR2
                                 ,P_NOTE              IN VARCHAR2
                                 ,P_USER_ID           IN NUMBER)
  IS
  BEGIN
        UPDATE EMPLOYER_DEPOSITs
        SET    STATUS = P_STATUS
           ,   NOTE           = P_NOTE
           ,   LAST_UPDATE_DATE = SYSDATE
           ,   LAST_UPDATED_BY = P_USER_ID
        WHERE  RECEIVABLE_ID = P_RECEIVABLE_ID;

        UPDATE EMPLOYER_DEPOSIT_DETAILS
        SET    STATUS = P_STATUS
           ,   NOTE           = P_NOTE
           ,   LAST_UPDATE_DATE = SYSDATE
           ,   LAST_UPDATED_BY = P_USER_ID
        WHERE  RECEIVABLE_ID = P_RECEIVABLE_ID;

  END UPDATE_ER_DEPOSIT_STATUS;
  */
    function get_receivable_entity_type (
        p_receivable_id in number
    ) return varchar2 is
        l_entity_type varchar2(30) := 'x';
    begin
        begin
            select
                entity_type
            into l_entity_type
            from
                receivable r,
                ar_invoice i
            where
                    r.invoice_id = i.invoice_id
                and r.receivable_id = p_receivable_id;

        exception
            when no_data_found then
                null;
        end;

        return l_entity_type;
    end get_receivable_entity_type;

    function calc_remaining_amt (
        p_check_amt     in number,
        p_returned_amt  in number,
        p_cancelled_amt in number
    ) return number is
    begin
        return p_check_amt - ( + nvl(p_returned_amt, 0) + nvl(p_cancelled_amt, 0) );
       --nvl(p_applied_amt,0) excluded from above, as prerequisite of reversal is fully paid

    end calc_remaining_amt;

end pc_receivable;
/

