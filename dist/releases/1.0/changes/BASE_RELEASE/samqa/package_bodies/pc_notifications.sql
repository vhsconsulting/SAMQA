-- liquibase formatted sql
-- changeset SAMQA:1754374054108 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_notifications.sql:null:b28cec692c7d577ecb701fda19f4f861d0242fc9:create

create or replace 
PACKAGE BODY                      SAMQA.PC_NOTIFICATIONS
IS
	-- commented by Joshi as ',' causing mail error on 01/11/2021
    --g_hrafsa_email VARCHAR2(3200)  := get_dept_email('2')||','||',techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com';
	g_hrafsa_email VARCHAR2(3200)   := get_dept_email('2')||','||'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com';
    g_finance_email VARCHAR2(3200)  := get_dept_email('3');


-- added by Joshi #5024
FUNCTION array_fill (p_array VARCHAR2_TBL, p_array_count NUMBER)
RETURN VARCHAR2_TBL
IS
  l_array VARCHAR2_TBL;
BEGIN
   FOR i IN 1 .. p_array_count
   LOOP
      IF (p_array.exists(i)) THEN
         l_array(i) := p_array(i);
      ELSE
         l_array(i) := null;
      END IF;

   END LOOP;
   RETURN l_array;
END;
-- code ends here  #5024

    PROCEDURE INSERT_ALERT (P_SUBJECT IN VARCHAR2,
                            P_MESSAGE IN VARCHAR2)
    IS
       L_NOTIFICATION_ID   NUMBER;
    BEGIN

       PC_NOTIFICATIONS.
       INSERT_NOTIFICATIONS (
          P_FROM_ADDRESS      => 'oracle@sterlingadministration.com',
          P_TO_ADDRESS        => 'IT-Team@sterlingadministration.com',--'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com',
          P_CC_ADDRESS        => 'IT-Team@sterlingadministration.com',--'customer.service@sterlingadministration.com',
          P_SUBJECT           => P_SUBJECT,
          P_MESSAGE_BODY      => P_MESSAGE,
          P_USER_ID           => 0,
          P_ACC_ID            => NULL,
          X_NOTIFICATION_ID   => L_NOTIFICATION_ID);

       UPDATE EMAIL_NOTIFICATIONS
          SET MAIL_STATUS = 'READY'
        WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
    END;
   FUNCTION get_email
   ( p_email  IN VARCHAR2
   )
   RETURN email_tbl_t PIPELINED DETERMINISTIC
   IS
     l_record_t email_row_t;
   BEGIN
      for x in (select
              trim( substr (txt,
                    instr (txt, ',', 1, level  ) + 1,
                    instr (txt, ',', 1, level+1)
                       - instr (txt, ',', 1, level) -1 ) )
                as token
               from (select ','||p_email||',' txt
                       from dual)
             connect by level <=
                length(p_email)-length(replace(p_email,',',''))+1)
     loop
        l_record_t.email := x.token;
        pipe row(l_record_t);
     end loop;

   END get_email;

  PROCEDURE INSERT_NOTIFICATIONS
   (P_FROM_ADDRESS IN VARCHAR2
   ,P_TO_ADDRESS   IN VARCHAR2
   ,P_CC_ADDRESS   IN VARCHAR2
   ,P_SUBJECT      IN VARCHAR2
   ,P_MESSAGE_BODY IN VARCHAR2
   ,P_USER_ID      IN NUMBER
   ,P_ACC_ID       IN NUMBER DEFAULT NULL
   ,X_NOTIFICATION_ID OUT NUMBER)
      IS
   BEGIN
     IF p_to_address IS NOT NULL THEN
          INSERT INTO EMAIL_NOTIFICATIONS
          (NOTIFICATION_ID
          ,FROM_ADDRESS
          ,TO_ADDRESS
          ,CC_ADDRESS
          ,SUBJECT
          ,MESSAGE_BODY
          ,MAIL_STATUS
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,ACC_ID)
          VALUES
          (NOTIFICATION_SEQ.NEXTVAL
          ,P_FROM_ADDRESS
          ,P_TO_ADDRESS
          ,P_CC_ADDRESS
          ,P_SUBJECT
          ,P_MESSAGE_BODY
          ,'OPEN'
          ,SYSDATE
          ,P_USER_ID
          ,SYSDATE
          ,P_USER_ID
          ,P_ACC_ID) RETURNING NOTIFICATION_ID INTO X_NOTIFICATION_ID;
     END IF;
   END INSERT_NOTIFICATIONS;
   PROCEDURE INSERT_EVENT_NOTIFICATIONS
  (P_EVENT_NAME   IN VARCHAR2
  ,P_EVENT_TYPE   IN VARCHAR2
  ,P_EVENT_DESC   IN VARCHAR2
  ,P_ENTITY_TYPE  IN VARCHAR2
  ,P_ENTITY_ID    IN VARCHAR2
  ,P_ACC_ID       IN NUMBER
  ,P_ACC_NUM      IN VARCHAR2
  ,P_PERS_ID      IN NUMBER
  ,P_USER_ID      IN NUMBER
  ,P_EMAIL        IN VARCHAR2
  ,P_TEMPLATE_NAME IN VARCHAR2
  ,X_RETURN_STATUS OUT VARCHAR2
  ,X_ERROR_MESSAGE OUT VARCHAR2)
  IS


  BEGIN
     X_RETURN_STATUS := 'S';
         INSERT INTO EVENT_NOTIFICATIONS
         (EVENT_ID
         ,EVENT_NAME
         ,EVENT_DESCRIPTION
         ,EVENT_TYPE
         ,ENTITY_ID
         ,ACC_ID
         ,ACC_NUM
         ,PERS_ID
         ,EMAIL
         ,ENTITY_TYPE
         ,TEMPLATE_NAME
         ,PROCESSED_FLAG
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY)
         VALUES
         (EVENT_NOTIFICATIONS_SEQ.NEXTVAL
         ,P_EVENT_NAME
         ,P_EVENT_DESC
         ,P_EVENT_TYPE
         ,P_ENTITY_ID
         ,P_ACC_ID
         ,P_ACC_NUM
         ,P_PERS_ID
         ,P_EMAIL
         ,P_ENTITY_TYPE
         ,P_TEMPLATE_NAME
         ,'N'
         ,SYSDATE
         ,p_user_id
         ,SYSDATE
         ,p_user_id);
  EXCEPTION
    WHEN OTHERS THEN
     X_RETURN_STATUS := 'E';
     X_ERROR_MESSAGE := SQLERRM;
             pc_log.log_error('create_fsa_disbursement,process_finance_claim: EVENT_NOTIFICATIONS ', SQLERRM );

  END INSERT_EVENT_NOTIFICATIONS;

  PROCEDURE SET_TOKEN (p_token IN VARCHAR2
                    ,p_string IN VARCHAR2
                    ,p_notif_id IN NUMBER)
  IS
  BEGIN

     UPDATE EMAIL_NOTIFICATIONS
      SET   MESSAGE_BODY = REPLACE(MESSAGE_BODY,'<<'||P_TOKEN||'>>',P_STRING)
     WHERE  notification_id =p_notif_id;
  END SET_TOKEN;
  PROCEDURE update_notification_status (P_NOTIFICATION_ID IN NUMBER,P_STATUS IN VARCHAR2)
  IS
  BEGIN
     UPDATE EMAIL_NOTIFICATIONS
     SET   MAIL_STATUS = 'CLOSED'
     WHERE NOTIFICATION_ID = P_NOTIFICATION_ID;
  END update_notification_status;

 PROCEDURE get_template_body(p_template_name IN VARCHAR2
                          , x_subject OUT VARCHAR2
              , x_template_body OUT VARCHAR2
              , x_cc_address OUT VARCHAR2
              , x_to_address OUT VARCHAR2)
IS
BEGIN

   FOR x IN ( SELECT a.template_subject
                   , a.template_body
                   , a.cc_address
                        , a.to_address
               FROM   NOTIFICATION_TEMPLATE A
              WHERE   A.TEMPLATE_NAME = p_template_name
                AND   A.STATUS = 'A')
   LOOP

      x_cc_address := x.cc_address;
      x_template_body := x.template_body;
      x_subject := x.template_subject;
      x_to_address := x.to_address;

   END LOOP;
END get_template_body;
PROCEDURE audit_review_notification
(p_payment_register_id  IN NUMBER
,p_template_name        IN VARCHAR2
,p_user_id              IN NUMBER)
IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
BEGIN

   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE   NOTIFICATION_TYPE = 'INTERNAL'
              AND     EVENT = 'DISBURSEMENT'
              AND     TEMPLATE_NAME= P_TEMPLATE_NAME
              AND     STATUS = 'A')
   LOOP

       PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => x.to_address
       ,P_CC_ADDRESS   => x.cc_address
       ,P_SUBJECT      => x.template_subject
       ,P_MESSAGE_BODY => x.template_body
       ,P_USER_ID      => p_user_id
       ,X_NOTIFICATION_ID => l_notif_id );

       FOR XX IN ( SELECT  ACC_NUM
                        ,  PC_PERSON.GET_PERSON_NAME(PERS_ID) NAME
                        ,  TRANS_DATE
                        ,  INITCAP(B.CLAIM_TYPE) CLAIM_TYPE
                              --,  DECODE(B.CLAIM_TYPE,11,'Provider',12,'Subscriber') CLAIM_TYPE
                        ,  CLAIM_AMOUNT
                        ,  PROVIDER_NAME
                        ,  NOTE
                        ,  ACC_ID
                    FROM   PAYMENT_REGISTER B
                        WHERE   B.PAYMENT_REGISTER_ID =p_payment_register_id)
       LOOP
               l_acc_id := xx.acc_id;
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',xx.name,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('FEE_DATE',xx.trans_date,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_TYPE',xx.claim_type,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT',xx.claim_amount,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('PROVIDER_NAME',xx.provider_name,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('NOTE',xx.note,l_notif_id);

       END LOOP;

       UPDATE EMAIL_NOTIFICATIONS
       SET    MAIL_STATUS = 'READY'
          ,   ACC_ID = l_acc_id
       WHERE  NOTIFICATION_ID  = l_notif_id;
   END LOOP;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END audit_review_notification;
PROCEDURE notify_fraud
IS
   l_sql VARCHAR2(3200);

BEGIN
 l_sql := ' select a.acc_num "Account Number", A.FRAUD_FLAG "Fraud"
                ,  A.id_verification_status "ID verification status"
                ,  get_user_name(c.last_updated_by) "Last updated by "
              from online_enrollment A, ACCOUNT B,ONLINE_USERS C
               where  A.fraud_flag = ''N'' and A.id_verification_status = ''1''
               AND    A.ACC_NUM = B.ACC_NUM
               and    replace(a.ssn,''-'') = c.tax_id
               AND    B.account_status in (2,3)
               AND   a.creation_date > sysdate-1
               and  blocked_flag = ''Y'' ';
  mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'fraud_details'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           ,l_sql
                           ,NULL
                           ,'Online Enrollment Fraud Details'
                           );

END notify_fraud;
-- not used
PROCEDURE notify_see_change_er_details
IS
   l_sql VARCHAR2(3200);
  BEGIN

     l_sql :=  'select distinct a.NAME "Employer_Name"
                         ,a.ACC_NUM "Account Number"
                         ,a.NO_OF_EMPLOYEES "No of Employees"
                         ,a.start_date "Start Date"
                         ,b.carrier_name "Carrier Name"
                         ,b.effective_date "Effective Date"
                         ,c.fee_setup "fee Setup"
                         ,d.name "SALES_REP"
                         ,e.FIRST_NAME||'' ''||e.LAST_NAME "BROKER_NAME"
                         ,f.agency_name "GA"
                 from EMP_OVERVIEW_V a,EMP_HEALTH_PLANS_V b,account c,salesrep d ,person e ,general_agent f
                where b.carrier_id In
             (select entrp_id from enterprise where en_code = 3 and upper(name) like ''SEE%'')
     and a.entrp_id=b.entrp_id and a.entrp_id=c.entrp_id
     and c.salesrep_id=d.salesrep_id(+)
     and c.broker_id(+)=e.pers_id and c.GA_id=f.GA_id(+)
      and b.status=''A'' ';
     -- order by b.carrier_name,c.fee_setup  desc ';


 mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                           'dana.difede@sterlingadministration.com'
                           ,'See_change_details.xls'
                           ,l_sql
                           ,NULL
                           ,'See Change Employer Details'
                           );
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_see_change_er_details;

PROCEDURE claim_notification
(p_payment_register_id  IN NUMBER
,p_user_id              IN NUMBER)
IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  num_tbl        number_tbl;
BEGIN
       pc_log.log_error('PC_CLAIM.audit_review_notification','p_payment_register_id '||p_payment_register_id );

   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
              AND    EVENT = 'DISBURSEMENT'
          AND    TEMPLATE_NAME = 'DATA_ENTRY_DISBURSEMENT'
              AND    STATUS = 'A')
   LOOP
        pc_log.log_error('PC_CLAIM.audit_review_notification','call notification' );
       FOR XX IN ( SELECT  ACC_NUM
                        ,  PC_PERSON.GET_PERSON_NAME(B.PERS_ID) NAME
                            ,  TRANS_DATE
                        ,  INITCAP(B.CLAIM_TYPE) CLAIM_TYPE
                              --,  DECODE(B.CLAIM_TYPE,11,'Provider',12,'Subscriber') CLAIM_TYPE
                               ,  CLAIM_AMOUNT
                          ,  PROVIDER_NAME
                            ,  B.NOTE
                              , C.EMAIL
                        , b.acc_id
                    FROM   PAYMENT_REGISTER B, PERSON C
                      WHERE   B.PAYMENT_REGISTER_ID =p_payment_register_id
                        AND   B.PERS_ID = C.PERS_ID
                        AND   CLAIM_TYPE  IN ('SUBSCRIBER','PROVIDER'))
       LOOP
               pc_log.log_error('PC_CLAIM.claim_notification','set token '||l_notif_id );

            l_acc_id      := xx.acc_id;

          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => xx.email
       ,P_CC_ADDRESS   => x.cc_address
       ,P_SUBJECT      => x.template_subject
       ,P_MESSAGE_BODY => x.template_body
       ,P_USER_ID      => p_user_id
       ,X_NOTIFICATION_ID => l_notif_id );
        pc_log.log_error('PC_CLAIM.claim_notification','l_notif_id '||l_notif_id );
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',xx.name,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT',xx.CLAIM_AMOUNT,l_notif_id);


          num_tbl(1) := p_user_id;
          add_notify_users(num_tbl,l_notif_id);


       END LOOP;



       UPDATE EMAIL_NOTIFICATIONS
       SET    MAIL_STATUS = 'READY'
         ,    acc_id = l_acc_id
       WHERE  NOTIFICATION_ID  = l_notif_id;
   END LOOP;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END claim_notification;

   -- Close Account
  PROCEDURE close_account_notification
  (p_person_name          IN VARCHAR2
  ,p_acc_id               IN NUMBER
  ,p_provider_name        IN VARCHAR2
  ,p_email                IN VARCHAR2
  ,p_claim_type           IN VARCHAR2
  ,p_user_id              IN NUMBER)
  IS
    l_message_body VARCHAR2(4000);
     l_notif_id    NUMBER;
     l_acc_id      NUMBER;
     num_tbl       number_tbl;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
           --   AND    EVENT = 'ACH_TRANSFER'
                AND    TEMPLATE_NAME = DECODE(p_claim_type,'HSA_TRANSFER','HSA_TRANSFER_TERMINATION'
                                                       , 'SUBSCRIBER','SUBSCRIBER_TERMINATION')
              AND    STATUS = 'A')
   LOOP


          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => p_email
       ,P_CC_ADDRESS   => x.cc_address
       ,P_SUBJECT      => x.template_subject
       ,P_MESSAGE_BODY => x.template_body
       ,P_USER_ID      => p_user_id
       ,P_ACC_ID       => p_acc_id
       ,X_NOTIFICATION_ID => l_notif_id );

       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',p_person_name,l_notif_id);
       IF p_provider_name IS NOT NULL THEN
          PC_NOTIFICATIONS.SET_TOKEN ('BANK_NAME',p_provider_name,l_notif_id);
       END IF;

        num_tbl(1):=p_user_id;
       add_notify_users(num_tbl,l_notif_id);


        UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;
        pc_log.log_error('PC_CLAIM.audit_review_notification','l_notif_id '||l_notif_id );
    END LOOP;
    exception
       WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END close_account_notification;
   -- ACH Terminated EE
   -- Called from pc_online.terminate_employee
  PROCEDURE ach_terminated_ee_notification
  (p_person_name          IN VARCHAR2
  ,p_acc_id               IN NUMBER
  ,p_transfer_date        IN VARCHAR2
  ,p_email                IN VARCHAR2
  ,p_template_name        IN VARCHAR2
  ,p_user_id              IN NUMBER)
  IS
    l_message_body VARCHAR2(4000);
    l_notif_id     NUMBER;
    num_tbl        number_tbl;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
              AND    EVENT = 'ACH_TRANSFER'
          AND    TEMPLATE_NAME = p_template_name
              AND    STATUS = 'A')
   LOOP
        pc_log.log_error('ach_terminated_ee_notification','call notification' );
        pc_log.log_error('ach_terminated_ee_notification','set token '||l_notif_id );


          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => p_email
       ,P_CC_ADDRESS   => x.cc_address
       ,P_SUBJECT      => x.template_subject
       ,P_MESSAGE_BODY => x.template_body
       ,P_USER_ID      => p_user_id
       ,P_ACC_ID       => p_acc_id
       ,X_NOTIFICATION_ID => l_notif_id );

       num_tbl(1):=p_user_id;
       add_notify_users(num_tbl,l_notif_id);

       PC_NOTIFICATIONS.SET_TOKEN ('NAME_OF_TERMED_EMPLOYEE','<b>'||p_person_name||'</b>',l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('TRANSFER_DATE',p_transfer_date,l_notif_id);
        UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;
    END LOOP;
  END ach_terminated_ee_notification;

   PROCEDURE insert_deny_claim_events
  (P_CLAIM_ID          IN NUMBER
  ,P_USER_ID           IN NUMBER)
  IS
    L_EVENT_TYPE VARCHAR2(30);
    l_return_status VARCHAR2(255) := 'S';
    l_error_message VARCHAR2(255);
    l_error         EXCEPTION;
    l_process_flag  VARCHAR2(255) := 'N';
    l_email_flg     VARCHAR2(1);
    l_ssn           person.ssn%type;
 BEGIN
   --  claim is fully denied
   pc_log.log_error('create_fsa_disbursement,process_finance_claim: insert_deny_claim_events,x.service_type ', P_CLAIM_ID  );

   FOR X IN ( SELECT nvl(pc_users.get_email(a.acc_num, a.acc_id, b.pers_id),e.email) email
                    ,b.claim_id
                    ,a.acc_id
                    ,a.acc_num
                    ,b.pers_id
                    ,b.claim_status status
                    ,e.ssn
                    ,b.approved_amount
               FROM   payment_register a
                  ,  claimn b
                  ,  person e
              WHERE   b.claim_id = p_claim_id
              AND     a.claim_id = b.claim_id
              AND     e.pers_id= b.pers_id
              AND     b.denied_amount > 0
              --Commented these conditions so that email gets sent for partial denial also.
             -- AND     NVL(b.approved_amount,0) = 0
              --AND     b.claim_status ='DENIED'
              --AND     b.claim_amount = b.denied_amount
)
   LOOP
        pc_log.log_error('create_fsa_disbursement,process_finance_claim: insert_deny_claim_events,x.email ', x.email  );

         IF x.email IS NULL THEN
              L_EVENT_TYPE := 'PAPER';
          ELSE
              L_EVENT_TYPE := 'EMAIL';
         END IF;

       l_email_flg := PC_NOTIFICATION2.GET_EMAIL_PREFERENCE(format_ssn(x.ssn),'CLAIM_DENIED');
       -- By default email should be sent
       l_email_flg := NVL(l_email_flg,'Y');

       IF l_email_flg = 'Y' THEN
          --Send patial denial notifications also.
       IF x.status = 'DENIED' THEN
          INSERT_EVENT_NOTIFICATIONS
         (P_EVENT_NAME   => 'CLAIM_DENIAL'
         ,P_EVENT_TYPE   => L_EVENT_TYPE
         ,P_EVENT_DESC   => 'Full Claim Denial for '||x.acc_num
         ,P_ENTITY_TYPE  => 'CLAIMN'
         ,P_ENTITY_ID    => x.claim_id
         ,P_ACC_ID       => x.acc_id
         ,P_ACC_NUM      => x.acc_num
         ,P_PERS_ID      => x.pers_id
         ,P_USER_ID      => P_USER_ID
         ,P_EMAIL        => x.email
         ,P_TEMPLATE_NAME => 'FULL_CLAIM_DENY'
         ,X_RETURN_STATUS => l_return_status
         ,X_ERROR_MESSAGE => l_error_message);

         -- Added by Joshi for 7920. Alert and notifications.
         -- For FSA/HRA, claim notificatin is handled from here and not from Trigger on claimsn table.
         -- call sms notificaton.
         PC_NOTIFICATION2.INSERT_EVENTS
                     (p_acc_id            => x.acc_id
                     ,p_pers_id           => x.pers_id
                     ,p_event_name        => 'CLAIM_DENIED'
                     ,p_entity_type       => 'CLAIMN'
                     ,p_entity_id         => x.claim_id);
         -- code ends her Joshi: 7920

       ELSE
          INSERT_EVENT_NOTIFICATIONS
             (P_EVENT_NAME   => 'CLAIM_PARTIAL_DENIAL'
             ,P_EVENT_TYPE   => L_EVENT_TYPE
             ,P_EVENT_DESC   => 'Partial Claim Denial for '||x.acc_num
             ,P_ENTITY_TYPE  => 'CLAIMN'
             ,P_ENTITY_ID    => x.claim_id
             ,P_ACC_ID       => x.acc_id
             ,P_ACC_NUM      => x.acc_num
             ,P_PERS_ID      => x.pers_id
             ,P_USER_ID      => P_USER_ID
             ,P_EMAIL        => x.email
             ,P_TEMPLATE_NAME => 'PARTIAL_CLAIM_DENY'
             ,X_RETURN_STATUS => l_return_status
             ,X_ERROR_MESSAGE => l_error_message);
         -- Added by Swamy for Ticket#7920.Alert and notifications.
         -- When the Claimn is Partially paid. i.e out of 100 claim amount, 60 is approved amount and 40 is denied amount, in this case SMS should be sent.
         IF NVL(x.approved_amount,0) > 0 THEN
             PC_NOTIFICATION2.INSERT_EVENTS
                     (p_acc_id            => x.acc_id
                     ,p_pers_id           => x.pers_id
                     ,p_event_name        => 'CLAIM_PARTIAL_PAID'
                     ,p_entity_type       => 'CLAIMN'
                     ,p_entity_id         => x.claim_id);
         END IF;

       END IF;
      END IF;

         IF l_return_status <> 'S' THEN
                  ROLLBACK;
                  RAISE  l_error;
         END IF;
   END LOOP;

  /*If the claim is .pay to provider. AND any amount goes to deductible

  If the claim is .pay to provider. AND there are insufficient funds in the
  account to pay the claim AND it is an HRA or FSA plan type

  If the claim is .pay to provider. AND there are insufficient funds in the
  account to pay the claim AND it is an HRP or HR5 plan type AND there are no
  further contributions scheduled*/

   FOR X IN ( SELECT pc_users.get_email(a.acc_num, a.acc_id, b.pers_id) email
                    ,b.claim_id
                    ,a.acc_id
                    ,a.acc_num
                    ,b.pers_id
                    ,a.pay_reason
                    ,b.denied_amount
                    ,b.deductible_amount
                    ,b.service_type
                    ,b.claim_status
                    ,PC_ACCOUNT.ACC_BALANCE(a.ACC_ID,b.PLAN_START_DATE,b.PLAN_END_DATE
                    ,pc_account.get_account_type(a.acc_id)
                    ,b.service_type) acc_balance
               FROM   payment_register a
                     ,  claimn b
              WHERE   b.claim_id = p_claim_id
              AND     a.claim_id = b.claim_id
              AND     a.pay_reason IN (11,19,12)
              AND     b.service_type IN ('HRA','FSA','HR5','HRP','LPF','TRN','DCA','PKG')
               AND    (NVL(deductible_amount,0) > 0
                     OR  (b.denied_amount > 0 AND claim_status IN ('PAID','APPROVED_NO_FUNDS','PARTIALLY_PAID'))))
   LOOP
            l_process_flag := 'N';
            IF x.acc_balance < 0 AND x.service_type IN ('HR5','HRP') THEN
            -- if this query returns some rows, that means we will get contributions
            -- in future
               FOR xx IN ( SELECT COUNT(*) CNT
                           FROM scheduler_master a, scheduler_details b
                          WHERE a.scheduler_id = b.scheduler_id
                          AND   b.acc_id = x.acc_id
                          AND   b.status = 'A'
                          AND   NVL(b.ee_amount,0)+NVL(b.er_amount,0) > 0
                          AND   a.payment_method = 'PAYROLL'
                          AND   a.payment_end_date > SYSDATE
                          AND   a.recurring_flag = 'Y')
               LOOP
                 IF xx.cnt = 0 THEN
                   l_process_flag := 'Y';
                 ELSE
                   l_process_flag := 'N';
                 END IF;
               END LOOP;
            ELSE
              l_process_flag := 'Y';
            END IF;-- x.acc_balance < 0 AND x.service_type IN ('HR5','HRP')
            IF l_process_flag  = 'Y' THEN
               IF x.email IS NULL THEN
                  L_EVENT_TYPE := 'PAPER';
               ELSE
                  L_EVENT_TYPE := 'EMAIL';
               END IF;

              FOR K IN (select ssn from person p where p.pers_id = x.pers_id) LOOP
                 l_ssn := k.ssn;
              END LOOP;

              l_email_flg := PC_NOTIFICATION2.GET_EMAIL_PREFERENCE(format_ssn(l_ssn),'CLAIM_DENIED');
              -- By default email should be sent
              l_email_flg := NVL(l_email_flg,'Y');
             IF l_email_flg = 'Y' THEN

              INSERT_EVENT_NOTIFICATIONS
             (P_EVENT_NAME   => 'CLAIM_PARTIAL_DENIAL'
             ,P_EVENT_TYPE   => L_EVENT_TYPE
             ,P_EVENT_DESC   => 'Partial Claim Denial for '||x.acc_num
             ,P_ENTITY_TYPE  => 'CLAIMN'
             ,P_ENTITY_ID    => x.claim_id
             ,P_ACC_ID       => x.acc_id
             ,P_ACC_NUM      => x.acc_num
             ,P_PERS_ID      => x.pers_id
             ,P_USER_ID      => P_USER_ID
             ,P_EMAIL        => x.email
             ,P_TEMPLATE_NAME => 'PARTIAL_CLAIM_DENY'
             ,X_RETURN_STATUS => l_return_status
             ,X_ERROR_MESSAGE => l_error_message);
             END IF;
             -- Added by Joshi for 7920. Alert and notifications.
             -- For FSA/HRA, claim notificatin is handled from here and not from Trigger on claimsn table.
             -- call sms notificaton.
                PC_NOTIFICATION2.INSERT_EVENTS
                     (p_acc_id            => x.acc_id
                     ,p_pers_id           => x.pers_id
                     ,p_event_name        => 'CLAIM_PARTIAL_PAID'
                     ,p_entity_type       => 'CLAIMN'
                     ,p_entity_id         => x.claim_id);
               -- code ends her Joshi: 7920

             IF l_return_status <> 'S' THEN
                ROLLBACK;
                RAISE  l_error;
             END IF;
          END IF;     --l_process_flag  = 'Y'
   END LOOP;
exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END insert_deny_claim_events;

PROCEDURE process_deny_notification
IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  l_process      VARCHAR2(1) := 'N';
  num_tbl number_tbl;
BEGIN
    --   pc_log.log_error('PC_CLAIM.audit_review_notification','p_payment_register_id '||p_payment_register_id );

   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.cc_address
                  ,  e.email email
                  ,  e.entity_id
                  ,  e.acc_num
                  ,  e.event_id
                  ,  pc_entrp.get_entrp_name(c.entrp_id) employer_name
                  ,  NVL(c.claim_amount,0) claim_amount
                  ,  NVL(c.deductible_amount,0) deductible_amount
                  ,  NVL(c.denied_amount,0) denied_amount
                  ,  NVL(c.claim_pending,0) claim_pending
                  ,  NVL(c.claim_paid,0) claim_paid
                  ,  c.claim_id
                  ,  D.FIRST_NAME||' '||D.LAST_NAME pers_name
                      ,  pc_lookups.GET_DENIED_REASON(c.denied_reason) denied_reason
                  ,  c.claim_status
                  ,  e.event_name
                  ,  pc_person.acc_id(c.pers_id) acc_id
                  ,  pc_lookups.get_fsa_plan_type(c.service_type) plan_type
                  ,  D.ADDRESS
                  ,  D.CITY
                  ,  D.STATE
                  ,  D.ZIP
                  ,  TO_CHAR(c.service_start_date,'MM/DD/YYYY') service_start_date
                  ,  C.PROV_NAME
                  ,  d.pers_id
              FROM   NOTIFICATION_TEMPLATE A
                    ,  EVENT_NOTIFICATIONS E
                    ,  CLAIMN C
                        ,  PERSON D
              WHERE  A.TEMPLATE_NAME = E.TEMPLATE_NAME
                AND    E.EVENT_NAME  IN ('CLAIM_DENIAL', 'CLAIM_PARTIAL_DENIAL','DEBIT_CLAIM_DENIAL')
                AND    A.STATUS = 'A'
                and    c.claim_id = e.entity_id
                  AND    D.PERS_ID = C.PERS_ID
                AND    ((C.DENIED_AMOUNT > 0 AND E.EVENT_NAME  IN ('CLAIM_DENIAL', 'CLAIM_PARTIAL_DENIAL'))
                       OR E.EVENT_NAME = 'DEBIT_CLAIM_DENIAL')
                AND    NVL(E.PROCESSED_FLAG,'N') = 'N'
                AND    E.EVENT_TYPE = 'EMAIL'
                AND    E.ENTITY_TYPE= 'CLAIMN')
   LOOP
        l_process := 'N';
        IF x.event_name in ('DEBIT_CLAIM_DENIAL', 'CLAIM_DENIAL') THEN
           l_process := 'Y';
           pc_log.log_error('processing insert,event name ',x.event_name);

        ELSE
            IF x.claim_status IN ('READY_TO_PAY','PAID','PARTIALLY_PAID') THEN
                l_process := 'Y';
                pc_log.log_error('processing insert,event name ',x.claim_status);

            END IF;
        END IF;
       IF l_process = 'Y' THEN
          pc_log.log_error('processing insert ',x.email);
          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
          (P_FROM_ADDRESS => 'benefits@sterlingadministration.com'
          ,P_TO_ADDRESS   => x.email
          ,P_CC_ADDRESS   => x.cc_address
          ,P_SUBJECT      => x.template_subject
          ,P_MESSAGE_BODY => x.template_body
          ,P_ACC_ID       => x.acc_id
          ,P_USER_ID      => 0
          ,X_NOTIFICATION_ID => l_notif_id );

          select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
          (select replace(ssn,'-')from person where pers_id=x.pers_id);
          add_notify_users(num_tbl,l_notif_id);

           PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',x.pers_name,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',x.acc_num,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',x.employer_name,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('DENIED_REASON',x.denied_reason,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT',format_money(x.claim_amount),l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLE_AMOUNT',format_money(x.deductible_amount),l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('DENIED_AMOUNT',format_money(x.denied_amount),l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_PAID',format_money(x.claim_paid),l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_ID',x.claim_id,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_PENDING',format_money(x.claim_pending),l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('DATE',to_char(sysdate,'MM/DD/YYYY'),l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',x.plan_type,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('ADDRESS',x.address,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CITY',x.city,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('STATE',x.state,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('ZIP_CODE',x.zip,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',x.plan_type,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('SERVICE_START_DATE',x.SERVICE_START_DATE,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('PROVIDER_NAME',x.PROV_NAME,l_notif_id);

           UPDATE EMAIL_NOTIFICATIONS
            SET    MAIL_STATUS = 'READY'
           WHERE  NOTIFICATION_ID  = l_notif_id;
                      pc_log.log_error('processing insert,l_notif_id ',l_notif_id);

           UPDATE EVENT_NOTIFICATIONS
            SET   processed_flag = 'Y'
           WHERE  event_id  = x.event_id;
       END IF;
   END LOOP;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.
    raise;
    dbms_output.put_line('error message '||SQLERRM);
END process_deny_notification;
  /** Issue no :9**/

 PROCEDURE plan_renewal_notification
  IS
    l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
   IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Renewals for the following month </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Renewals for the following month  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT PC_ENTRP.GET_ENTRP_NAME(ENTRP_ID) "Employer Name"
                    ,PC_ENTRP.GET_ACC_NUM(ENTRP_ID) "Account Number"
                    ,PLAN_TYPE "Plan Type"
                    ,TO_CHAR(PLAN_START_DATE,''MM/DD/YYYY'') "Plan Start Date"
                    ,TO_CHAR(PLAN_END_DATE,''MM/DD/YYYY'') "Plan End Date"
              FROM BEN_PLAN_ENROLLMENT_SETUP
              WHERE plan_end_date BETWEEN SYSDATE AND LAST_DAY(SYSDATE)
              AND   STATUS IN (''A'',''I'')
              AND   ENTRP_ID IS NOT NULL ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email ||','||g_finance_email
                           ,'hra_fsa_renewals'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Renewals for the month of '||to_char(sysdate,'MM/DD/YYYY')||
                 to_char(LAST_DAY(SYSDATE),'MM/DD/YYYY'));
   END IF;
   exception
      WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END;
  /** Issue no :4**/
   PROCEDURE non_discrim_notification
  IS
     L_NOTIFICATION_ID NUMBER;
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Non-Discrimination Testing Notification </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Non-Discrimination Testing Notification  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT DISTINCT PC_ENTRP.GET_ENTRP_NAME(ENTRP_ID) ENTRP_NAME
                    ,  PLAN_END_DATE
                    ,  PLAN_START_DATE
                FROM BEN_PLAN_ENROLLMENT_SETUP
                WHERE ((PLAN_TYPE IN (''HRA'',''HR5'',''HR4'',''ACO'',''HRP'') AND
                        TRUNC(PLAN_START_DATE)+(TRUNC(PLAN_END_DATE-PLAN_START_DATE)/2) =TRUNC(SYSDATE)
                        OR  TRUNC(PLAN_START_DATE+30) =TRUNC(SYSDATE))
                    OR (PLAN_TYPE IN (''FSA'',''LPF'',''DCA'')
                       AND
                        (TRUNC(SYSDATE-PLAN_START_DATE)=60
                        OR  TRUNC(PLAN_END_DATE-SYSDATE)=30)))
                AND   ENTRP_ID IS NOT NULL AND STATUS IN (''A'',''I'')';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email
                           ,'hra_fsa_non_discrimination'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Non-discrimination testing reminder notification on '||to_char(sysdate,'MM/DD/YYYY'));
  exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END non_discrim_notification;

  PROCEDURE send_email_on_ofac_results
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>OFAC batch results from Veratad </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>OFAC batch results from Veratad  </p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT B.ACC_NUM
               , A.TRANSACTION_ID
               , A.OFAC_TEXT
               , A.VERIFICATION_DATE
               , A.OFAC_CODE
               , A.OFACREFERENCE
             FROM   veratad_ofac_external A
              ,  ACCOUNT B
             WHERE  A.ACC_NUM = B.ACC_NUM
             AND    A.OFAC_TEXT IN (''positive'')';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                           'lola.christensen@sterlingadministration.com,dana.ramos@sterlingadministration.com '
                           ,'ofac_results'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'OFAC batch results from Veratad on '||to_char(sysdate,'MM/DD/YYYY'));

EXCEPTION
  WHEN OTHERS THEN
     NULL;
END send_email_on_ofac_results;

PROCEDURE insert_inactive_bank_event
 (P_BANK_ACCT_ID      IN NUMBER
  ,P_USER_ID           IN NUMBER
  ,p_account_type      IN VARCHAR2)
  IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  l_process      VARCHAR2(1) := 'N';
  l_cc_address   VARCHAR2(255);
  l_template_subject VARCHAR2(4000);
  l_template_body  VARCHAR2(32000);
  l_content        VARCHAR2(32000);
  num_tbl number_tbl;
BEGIN
    --   pc_log.log_error('PC_CLAIM.audit_review_notification','p_payment_register_id '||p_payment_register_id );

   FOR x IN ( SELECT a.template_subject
                        ,  a.template_body
                        ,  a.cc_address
                    FROM   NOTIFICATION_TEMPLATE A
                   WHERE   A.TEMPLATE_NAME = DECODE(p_account_type,'HSA','INVALID_HSA_BANK_ACCOUNT','INVALID_HRAFSA_BANK_ACCOUNT')
                     AND    A.STATUS = 'A')
   LOOP

      l_cc_address := x.cc_address;
      l_template_body := x.template_body;
      l_template_subject := x.template_subject;

   END LOOP;
  FOR X IN ( SELECT pc_users.get_email(b.acc_num, b.acc_id, b.pers_id) email
                    ,a.bank_acct_id
                    ,b.acc_id
                    ,b.acc_num
                    ,b.pers_id
                        ,a.bank_name
                        ,b.entrp_id
                    ,DECODE(b.pers_id, NULL, pc_entrp.get_entrp_name(b.entrp_id)
                    ,pc_person.get_person_name(b.pers_id)) name
                    ,DECODE(b.account_type,'HSA','HSA','HRAFSA') acc_type
                    ,DECODE(b.account_type
                                   ,'HSA','Health Saving Account'
                                     ,'HRA','Health Reimbursement account'
                                     ,'FSA','Flexible Spending Account') ACCOUNT_TYPE
                    , DECODE(b.account_type
                                   ,'HSA','customer.service@sterlingadministration.com',
                                   'benefits@sterlingadministration.com') from_address
               FROM   user_bank_acct_v a, account b
              WHERE   a.bank_acct_id = p_bank_acct_id
              AND     A.acc_id = b.acc_id
              AND     b.account_type = DECODE(p_account_type,'HSA','HSA',b.account_type) )
   LOOP

      IF x.acc_type = p_account_type THEN
            l_content := null;
                 PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                (P_FROM_ADDRESS => x.from_address
                ,P_TO_ADDRESS   => x.email
                ,P_CC_ADDRESS   => l_cc_address
                ,P_SUBJECT      => l_template_subject
                ,P_MESSAGE_BODY => l_template_body
                ,P_ACC_ID       => x.acc_id
                ,P_USER_ID      => 0
                ,X_NOTIFICATION_ID => l_notif_id );

                 PC_NOTIFICATIONS.SET_TOKEN ('NAME',x.name,l_notif_id);
                select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
                (select replace(ssn,'-')from person where pers_id=x.pers_id);
                add_notify_users(num_tbl,l_notif_id);

               IF p_account_type <> 'HSA' THEN
                 FOR xX IN ( SELECT  a.claim_id, pc_lookups.GET_FSA_PLAN_TYPE(a.service_type) service_type
                                  , to_char(a.claim_date_start,'MM/DD/YYYY') claim_date
                                 ,  ROUND(a.claim_amount,2) claim_amount
                             FROM   claimn a, payment_register b
                             WHERE   b.bank_acct_id = x.bank_acct_id
                               AND   a.service_type <> 'HSA'
                               AND   a.claim_id = b.claim_id
                               AND   a.claim_status NOT IN ('PAID','PARTIALLY_PAID','DENIED','PAID','ERROR','CANCELLED','PROCESSED'))
                 LOOP
                    l_content := l_content||'<tr><td>'||xx.claim_id||'</td><td>'||xx.claim_date||'</td><td>'||xx.claim_amount||
                                '</td><td>'||xx.service_type;
                 END LOOP;
                 PC_NOTIFICATIONS.SET_TOKEN ('CONTENT',l_content,l_notif_id);
               ELSE

                 FOR xX IN ( SELECT  transaction_id,  total_amount amount
                                  , decode(transaction_type,'C','Contribution','Disbursement') transaction_type
                                  , to_char(transaction_date,'MM/DD/YYYY') transaction_date
                             FROM   ach_transfer
                             WHERE  bank_acct_id = x.bank_acct_id
                              AND   status IN (1,2))
                 LOOP
                   l_content := l_content||'<tr><td>'||xx.transaction_id||'</td><td>'||xx.transaction_date||'</td><td>'||xx.amount||
                                '</td><td>'||xx.transaction_type;

                 END LOOP;
                 PC_NOTIFICATIONS.SET_TOKEN ('CONTENT',l_content,l_notif_id);

               END IF;

                 UPDATE EMAIL_NOTIFICATIONS
                  SET    MAIL_STATUS = 'READY'
                 WHERE  NOTIFICATION_ID  = l_notif_id;

      END IF;
    END LOOP;
    exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END insert_inactive_bank_event;
PROCEDURE send_email_on_id_results
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>ID Verification batch results from Veratad </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>ID Verification batch results from Veratad  </p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT a.SEQUENCE_NO
                    ,a.ACC_NUM
                ,DECODE(a.STATUS,1,''ID Verification Failed'',''ID Verification Passed'') STATUS
                ,a.MESSAGE
                ,a.TRANSACTION_ID
           --     ,a.VERIFICATION_DATE
                ,a.AGE_CODE
                ,a.AGE_TEXT
                ,a.DECEASED_CODE
                ,a.DECEASED_TEXT
                ,a.AGE_DELTA
                ,a.SSN_CODE
                ,a.SSN_TEXT
                ,a.OFAC_CODE
                ,a.OFAC_TEXT
          FROM   veratad_external A
              ,  ACCOUNT B
          WHERE  A.ACC_NUM = B.ACC_NUM
          AND    A.OFAC_TEXT IN (''positive'',''negative'')';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                           'dana.ramos@sterlingadministration.com,lola.christensen@sterlingadministration.com '
                           ,'id_results'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'ID verification batch results from Veratad on '||to_char(sysdate,'MM/DD/YYYY'));

EXCEPTION

       WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_on_id_results;

  PROCEDURE suspended_60days_notification
  IS
     l_message_body VARCHAR2(4000);
     l_notif_id     NUMBER;
     l_acc_id      NUMBER;
     l_cc_address   VARCHAR2(255);
     l_template_subject VARCHAR2(4000);
     l_template_body  VARCHAR2(32000);
     l_content        VARCHAR2(32000);
     num_tbl number_tbl;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
          AND    TEMPLATE_NAME = 'HSA_SUSPENDED_ACCOUNT'
              AND    STATUS = 'A')
   LOOP

      l_cc_address := x.cc_address;
      l_template_body := x.template_body;
      l_template_subject := x.template_subject;

   END LOOP;

   FOR X IN (select PC_PERSON.get_person_name(PERS_ID) NAME
                  , ACC_ID
               , EMAIL
               , ACC_NUM
             from SUSPENDED_ACCTS_V
         where activedays = 60 AND email is not null)
   LOOP
          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => x.email
       ,P_CC_ADDRESS   => 'customer.service@sterlingadministration.com'
       ,P_SUBJECT      => REPLACE(l_template_subject,'<<ACC_NUM>>',x.acc_num)
       ,P_MESSAGE_BODY => l_template_body
       ,P_USER_ID      => 0
       ,P_ACC_ID       => x.acc_id
       ,X_NOTIFICATION_ID => l_notif_id );

       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',x.name,l_notif_id);

       select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
       (select replace(ssn,'-')from person where pers_id=pc_person.pers_id_from_acc_id(x.acc_id));
       add_notify_users(num_tbl,l_notif_id);

        UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;
     END LOOP;
     exception
        WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END suspended_60days_notification;

  PROCEDURE catchup_55_notification
  IS
     l_message_body VARCHAR2(4000);
     l_notif_id     NUMBER;
     l_acc_id      NUMBER;
     l_cc_address   VARCHAR2(255);
     l_template_subject VARCHAR2(4000);
     l_template_body  VARCHAR2(32000);
     l_content        VARCHAR2(32000);
     num_tbl number_tbl;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
          AND    TEMPLATE_NAME = 'HSA_CATCHUP55'
              AND    STATUS = 'A')
   LOOP

      l_cc_address := x.cc_address;
      l_template_body := x.template_body;
      l_template_subject := x.template_subject;

   END LOOP;

   FOR X IN (select acc_id,name, email_address  from new_catchup_accounts_v
             where email_address is not null order by name)
   LOOP
          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => x.email_address
       ,P_CC_ADDRESS   => 'customer.service@sterlingadministration.com'
       ,P_SUBJECT      => l_template_subject
       ,P_MESSAGE_BODY => l_template_body
       ,P_USER_ID      => 0
       ,P_ACC_ID       => x.acc_id
       ,X_NOTIFICATION_ID => l_notif_id );

       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',x.name,l_notif_id);

       select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
       (select replace(ssn,'-')from person where pers_id=pc_person.pers_id_from_acc_id(x.acc_id));
       add_notify_users(num_tbl,l_notif_id);

        UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;
     END LOOP;
     exception
        WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END catchup_55_notification;

  -- not used
  PROCEDURE catchup_65_notification
  IS
     l_message_body VARCHAR2(4000);
     l_notif_id     NUMBER;
     l_acc_id      NUMBER;
     l_cc_address   VARCHAR2(255);
     l_template_subject VARCHAR2(4000);
     l_template_body  VARCHAR2(32000);
     l_content        VARCHAR2(32000);
     num_tbl          number_tbl;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
          AND    TEMPLATE_NAME = 'HSA_CATCHUP65'
              AND    STATUS = 'A')
   LOOP

      l_cc_address := x.cc_address;
      l_template_body := x.template_body;
      l_template_subject := x.template_subject;

   END LOOP;

   FOR X IN (select acc_id,name, email_address  from NEW_CATCHUP_65_AGE_V
             where email_address is not null order by name)
   LOOP
          PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS   => x.email_address
       ,P_CC_ADDRESS   => 'customer.service@sterlingadministration.com'
       ,P_SUBJECT      => l_template_subject
       ,P_MESSAGE_BODY => l_template_body
       ,P_USER_ID      => 0
       ,P_ACC_ID       => x.acc_id
       ,X_NOTIFICATION_ID => l_notif_id );

       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',x.name,l_notif_id);
       select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
       (select replace(ssn,'-')from person where pers_id=pc_person.pers_id_from_acc_id(x.acc_id));
       add_notify_users(num_tbl,l_notif_id);


        UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;
     END LOOP;
     exception
        WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END catchup_65_notification;
PROCEDURE send_email_hra_fsa_renewal
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Renewals for the following month </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Renewals for the following month  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT PC_ENTRP.GET_ENTRP_NAME(ENTRP_ID) "Employer Name"
                    ,PC_ENTRP.GET_ACC_NUM(ENTRP_ID) "Account Number"
                    ,PLAN_TYPE "Plan Type"
                    ,TO_CHAR(PLAN_START_DATE,''MM/DD/YYYY'') "Plan Start Date"
                    ,TO_CHAR(PLAN_END_DATE,''MM/DD/YYYY'') "Plan End Date"
              FROM BEN_PLAN_ENROLLMENT_SETUP
              WHERE plan_end_date BETWEEN SYSDATE AND LAST_DAY(SYSDATE)
              AND   ENTRP_ID IS NOT NULL AND STATUS IN (''A'',''I'') ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email ||',patricia.reimer@sterlingadministration.com'
                           ,'hra_fsa_renewals'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                          ,'HRA/FSA Renewals for the month of '||to_char(sysdate,'MM/DD/YYYY')||
                 to_char(LAST_DAY(SYSDATE),'MM/DD/YYYY'));
 --  END IF;
exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_hra_fsa_renewal;
PROCEDURE email_hrafsa_address_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Employer/Employee Demographic Creation Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Employer/Employee Demographic Creation Errors in BPS  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT DISTINCT A.ACTION_CODE "Action"
                  , A.EMPLOYEE_ID "Account Number"
                  , RECORD_TRACKING_NUMBER "Reference Number"
                  , A.DETAIL_RESPONSE_CODE "Error Message"
              FROM  METAVANTE_ERRORS A, ACCOUNT B
             WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.''
                                         ,''Employer ID does not exist or empty.''
                                       ,''Employee key does not exist or empty.''
                                       ,''Dependent does not exist.'')
             AND   A.ACTION_CODE IN (''Address Update'',''Employer Demographic Creation'',''Card Creation'')
             AND   A.EMPLOYEE_ID = B.ACC_NUM
             AND   B.ACCOUNT_TYPE IN (''HRA'',''FSA'')
             AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE)-1';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email
                           ,'hra_fsa_address_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Employer/Employee Demographic Creation Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_address_error;

PROCEDURE email_hrafsa_deductible
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Claims Deductible Report for Pending Review Claims </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Claims Deductible Report for Pending Review Claims  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT claim_id "Claim Number"
                  ,  acc_num  "Account Number"
                  ,  plan_type "Service/Plan Type"
                  ,  plan_start_date "Plan Start Date"
                  ,  plan_end_date  "Plan end Date"
                  ,  claim_amount "Claim Amount"
                  ,  annual_election "Annual Election"
                  ,  deductible_amount "Deductible Amount"
                  ,  approved_amount "Approved Amount"
              FROM claims_deductible_v WHERE 1 = 1 ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email
                           ,'claim_deductible'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claims Deductible Report for Pending Review Claims '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_deductible;
PROCEDURE email_hrafsa_enrollments
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Enrollment Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Enrollment Report  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT  a.first_name||'' ''||a.middle_name||'' ''||a.last_name "Employee Name"
                          , pc_entrp.get_entrp_name(a.entrp_id) "Employer Name"
                          , b.acc_num "Account Number"
                          , to_char(b.start_date,''MM/DD/YYYY'') "Account Effective Date"
                          , to_char(c.EFFECTIVE_DATE ,''MM/DD/YYYY'') "Plan Effective Date"
                          , c.plan_type "Plan Type"
                          , to_char(c.plan_start_date,''MM/DD/YYYY'') "Plan Start Date"
                          , to_char(c.plan_end_date,''MM/DD/YYYY'') "Plan End Date"
                         ,   FIRST_PAYROLL_DATE  "First Payroll Date"
                         , PAY_CONTRB "Pay Contribution"
                         , NO_OF_PERIODS "No of Periods"
                         , PAY_CYCLE "Pay Cycle"
                         , d.EFFECTIVE_DATE  "Payroll Effective Date"
                         ,   INITCAP(b.enrollment_source) "Enrollment Source"
                    FROM    ACCOUNT B, PERSON a, BEN_PLAN_ENROLLMENT_SETUP C, PAY_DETAILS D
                    WHERE   B.ACCOUNT_TYPE IN (''HRA'',''FSA'')
                     AND    A.PERS_ID = B.PERS_ID
                     AND    A.ENTRP_ID <> 7963
                     AND    C.STATUS IN (''A'',''I'')
                     AND    C.ACC_ID = B.ACC_ID
                     AND    C.BEN_PLAN_ID = D.BEN_PLAN_ID(+)
                     AND    C.ACC_ID = D.ACC_ID(+)
                     AND    TRUNC(B.CREATION_DATE) = TRUNC(SYSDATE)-1
                        ';


    dbms_output.put_line('sql '||l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                             ,g_hrafsa_email||','||'VHSTeam@sterlingadministration.com'
                           ,'hra_fsa_enrollment'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Enrollment Report for '||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_enrollments;
PROCEDURE FSA_Employer_Balances
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
   --IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>FSA Employer Balance Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>FSA Employer Balance Report  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT ACC_NUM
                  ,  PRODUCT_TYPE
                  ,  ER_BALANCE
                  ,  EMPLOYER_NAME
              FROM EMPLOYER_BALANCE_MV WHERE PRODUCT_TYPE = ''FSA'' ';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_cc_email ||',shavee.kapoor@sterlingadministration.com'
                           ,'fsa_employer_balance'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                          , 'FSA Balance Report for'||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END FSA_Employer_Balances;

PROCEDURE HRA_Employer_Balances
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  --IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA Employer Balance Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA Employer Balance Report </p>
       </table>
        </body>
        </html>';
        l_sql := 'SELECT ACC_NUM
                  ,  PRODUCT_TYPE
                  ,  ER_BALANCE
                  ,  EMPLOYER_NAME
              FROM EMPLOYER_BALANCE_MV WHERE PRODUCT_TYPE = ''HRA'' ';




     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_cc_email ||',shavee.kapoor@sterlingadministration.com'
                           ,'hra_employer_balance'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                          , 'HRA Balance Report for'||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END HRA_Employer_Balances;

PROCEDURE Closed_HSA_Account_Balances
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
   --IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Closed HSA Accounts with Balance Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Closed HSA Accounts Balance Report  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT  ACC.acc_num,PC_ACCOUNT.acc_balance(ACC.ACC_ID) AS BAL,P.FIRST_NAME,P.LAST_NAME,ACC.END_DATE AS "CLOSE DATE"
                           FROM person P,ACCOUNT ACC
                WHERE ACC.ACCOUNT_TYPE  = ''HSA''
              AND ACC.account_status=4
                AND P.PERS_ID=ACC.PERS_ID
                AND PC_ACCOUNT.acc_balance(ACC.ACC_ID)>0';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'Dana.Christensen@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'Closed_HSA_Account_Balances'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                          , 'Closed HSA Accounts Balance Report for'||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END Closed_HSA_Account_Balances;

PROCEDURE email_hrafsa_dep_card_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Dependent Card Creation Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Dependent Card Creation Errors in BPS  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT distinct A.ACTION_CODE "Action"
                   , C.FIRST_NAME "First Name"
                   , C.LAST_NAME "Last Name"
                   , A.EMPLOYEE_ID "Account Number"
                   , RECORD_TRACKING_NUMBER "Reference Number"
                  ,  A.DETAIL_RESPONSE_CODE "Error Message"
                FROM  METAVANTE_ERRORS A, ACCOUNT B, PERSON C
                WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.'',''Employer ID does not exist or empty.''
                                                       ,''Employee key does not exist or empty.''
                                                  ,''Dependent does not exist.'')
                AND   A.ACTION_CODE =  ''Dependant Card Creation''
                AND   A.EMPLOYEE_ID = B.ACC_NUM
                AND   C.PERS_ID = A.DEPENDANT_ID
                AND   B.ACCOUNT_TYPE IN (''HRA'',''FSA'')
                AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE)-1 ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           , g_hrafsa_email||','||g_cc_email
                           ,'hra_fsa_dep_card_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Dependent Creation Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_dep_card_error;
PROCEDURE email_hrafsa_payment_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Payment Posting Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Payment Posting Errors in BPS  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT distinct A.ACTION_CODE "Action"
                 , A.EMPLOYEE_ID "Account Number"
                     , RECORD_TRACKING_NUMBER "Reference Number"
                 , TO_CHAR(C.PAY_DATE,''MM/DD/YYYY'') "Payment Date"
                 , C.AMOUNT "Payment Amount"
                 , C.PLAN_TYPE "Plan Type"
                 , PC_ENTRP.GET_ENTRP_NAME(D.ENTRP_ID) "Employer Name"
                 , A.DETAIL_RESPONSE_CODE "Error Message"
            FROM  METAVANTE_ERRORS A, ACCOUNT B, PAYMENT C, PERSON D
            WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.''
                              ,''Employer ID does not exist or empty.''
                                    ,''Employee key does not exist or empty.''
                            ,''Dependent does not exist.''
                                    ,''Cannot find Participant benefit account or Dependent account.'')
            AND   A.ACTION_CODE  = ''Payment''
            AND   A.EMPLOYEE_ID = B.ACC_NUM
            AND   C.ACC_ID = B.ACC_ID
            AND   D.PERS_ID= B.PERS_ID
            AND   B.ACCOUNT_TYPE IN (''HRA'',''FSA'')
            AND   A.RECORD_TRACKING_NUMBER = C.CHANGE_NUM
            AND   TRUNC(A.CREATION_DATE) >= TRUNC(SYSDATE)-1   ';

      pc_log.log_error('email_hrafsa_payment_error',l_sql);


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           , g_hrafsa_email||','||g_cc_email||',cindy.carrillo@sterlingadministration.com'
                          -- , g_cc_email
                           ,'hra_fsa_payment_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Payment Posting Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_payment_error;



PROCEDURE email_hrafsa_receipt_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Receipt Posting Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Receipt Posting Errors in BPS   </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT distinct A.ACTION_CODE "Action"
                 , A.EMPLOYEE_ID "Account Number"
                     , RECORD_TRACKING_NUMBER "Reference #"
                 , TO_CHAR(C.FEE_DATE,''MM/DD/YYYY'') "Receipt Date"
                 , NVL(C.AMOUNT,0)+NVL(C.AMOUNT_ADD,0) "Receipt Amount"
                 , C.PLAN_TYPE "Plan Type"
                 , PC_ENTRP.GET_ENTRP_NAME(D.ENTRP_ID) "Employer Name"
                 , A.DETAIL_RESPONSE_CODE "Error Message"
                 , E.DISBURSABLE_BALANCE "BPS Balance"
                 , PC_ACCOUNT.ACC_BALANCE(B.ACC_ID, E.PLAN_START_DATE,E.PLAN_END_DATE,B.ACCOUNT_TYPE,E.PLAN_TYPE) "SAM Balance"
            FROM  METAVANTE_ERRORS A, ACCOUNT B, INCOME C, PERSON D
               ,  METAVANTE_CARD_BALANCES E
            WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.''
                              ,''Employer ID does not exist or empty.''
                              ,''Employee key does not exist or empty.''
                              ,''Dependent does not exist.''
                              ,''Cannot find Participant benefit account or Dependent account.'')
            AND   A.ACTION_CODE  = ''Receipt''
            AND   A.EMPLOYEE_ID = B.ACC_NUM
              AND   E.ACC_NUM = B.ACC_NUM
              AND   C.PLAN_TYPE = E.PLAN_TYPE
            AND   B.ACC_ID = C.ACC_ID
            AND   B.PERS_ID = D.PERS_ID
            AND  C.DEBIT_CARD_POSTED = ''N''
            AND   B.ACCOUNT_TYPE IN (''HRA'',''FSA'')
            AND   A.RECORD_TRACKING_NUMBER = C.CHANGE_NUM
            AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE)-1 ';

      pc_log.log_error('email_hrafsa_receipt_error',l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                           , g_hrafsa_email||','||g_cc_email||',cindy.carrillo@sterlingadministration.com'
                           ,'hra_fsa_receipt_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Receipt Posting Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_receipt_error;

PROCEDURE email_hsa_address_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HSA Employee Demographic Creation Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HSA Employee Demographic Creation Errors in BPS   </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT DISTINCT A.ACTION_CODE "Action"
                  , A.EMPLOYEE_ID "Account Number"
                  , RECORD_TRACKING_NUMBER "Reference Number"
                  , A.DETAIL_RESPONSE_CODE "Error Message"
              FROM  METAVANTE_ERRORS A, ACCOUNT B
             WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.''
                                         ,''Employer ID does not exist or empty.''
                                       ,''Employee key does not exist or empty.''
                                       ,''Dependent does not exist.'')
             AND   A.ACTION_CODE IN (''Address Update'',''Employer Demographic Creation'',''Card Creation'')
             AND   A.EMPLOYEE_ID = B.ACC_NUM
             AND   B.ACCOUNT_TYPE = ''HSA''
             AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE)';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hsa_email||','||g_cc_email
                           ,'hra_fsa_address_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HSA Employer/Employee Demographic Creation Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hsa_address_error;
PROCEDURE email_hsa_dep_card_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HSA Dependent Card Creation Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>>HSA Dependent Card Creation Errors in BPS  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT distinct A.ACTION_CODE "Action"
                    , C.FIRST_NAME "First Name"
                    , C.LAST_NAME "Last Name"
                    , A.EMPLOYEE_ID "Account Number"
                    , RECORD_TRACKING_NUMBER "Reference #"
                    , A.DETAIL_RESPONSE_CODE "Error Message"
                FROM  METAVANTE_ERRORS A, ACCOUNT B, PERSON C
                WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.'',''Employer ID does not exist or empty.''
                                          ,''Employee key does not exist or empty.''
                                                  ,''Dependent does not exist.'')
                AND   A.ACTION_CODE =  ''Dependant Card Creation''
                AND   A.EMPLOYEE_ID = B.ACC_NUM
                AND   C.PERS_ID = REPLACE(RECORD_TRACKING_NUMBER,''CNEWDEP_'')
                AND   B.ACCOUNT_TYPE = ''HSA''
                AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE) ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hsa_email||','||g_cc_email
                           ,'hsa_dep_card_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HSA Dependent Creation Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hsa_dep_card_error;
PROCEDURE email_hsa_payment_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HSA Payment Posting Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HSA Payment Posting Errors in BPS  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT distinct A.ACTION_CODE "Action"
                 , A.EMPLOYEE_ID "Account Number"
                     , RECORD_TRACKING_NUMBER "Reference Number"
                 , TO_CHAR(C.PAY_DATE,''MM/DD/YYYY'') "Payment Date"
                 , C.AMOUNT "Payment Amount"
                 , A.DETAIL_RESPONSE_CODE "Error Message"
                 , PC_ENTRP.GET_ENTRP_NAME(D.ENTRP_ID) "Employer Name"
                 , PC_ACCOUNT.ACC_BALANCE(B.ACC_ID) "SAM Balance"
                 , e.disbursable_balance "BPS Balance"
            FROM  METAVANTE_ERRORS A, ACCOUNT B, PAYMENT C, PERSON D,metavante_card_balances e
            WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.''
                              ,''Employer ID does not exist or empty.''
                                    ,''Employee key does not exist or empty.''
                            ,''Dependent does not exist.''
                                    ,''Cannot find Participant benefit account or Dependent account.'')
            AND   A.ACTION_CODE  = ''Payment''
            AND   B.ACC_NUM = E.ACC_NUM
            AND   A.EMPLOYEE_ID = B.ACC_NUM
            AND   D.PERS_ID = B.PERS_ID
            AND   B.ACC_ID= C.ACC_ID
            AND   B.ACCOUNT_TYPE = ''HSA''
            AND   A.RECORD_TRACKING_NUMBER = C.CHANGE_NUM
            AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE)';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hsa_email||','||g_cc_email||',sumithra.bai@sterlingadministration.com,franco.espinoza@sterlingadministration.com'
                           ,'hsa_payment_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HSA Payment Posting Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hsa_payment_error;



PROCEDURE email_hsa_receipt_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HSA Receipt Posting Errors in BPS  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HSA Receipt Posting Errors in BPS  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT distinct A.ACTION_CODE "Action"
                 , A.EMPLOYEE_ID "Account Number"
                 , RECORD_TRACKING_NUMBER "Reference Number"
                 , TO_CHAR(C.FEE_DATE,''MM/DD/YYYY'') "Receipt Date"
                 , NVL(C.AMOUNT,0)+NVL(C.AMOUNT_ADD,0) "Receipt Amount"
                 , PC_ENTRP.GET_ENTRP_NAME(D.ENTRP_ID) "Employer Name"
                 , A.DETAIL_RESPONSE_CODE "Error Message"
                 , PC_ACCOUNT.ACC_BALANCE(B.ACC_ID) "SAM Balance"
                 , e.disbursable_balance "BPS Balance"
            FROM  METAVANTE_ERRORS A, ACCOUNT B, INCOME C, PERSON D,metavante_card_balances e
            WHERE A.DETAIL_RESPONSE_CODE NOT IN (''Success.''
                              ,''Employer ID does not exist or empty.''
                             ,''Employee key does not exist or empty.''
                            ,''Dependent does not exist.''
                            ,''Cannot find Participant benefit account or Dependent account.'')
            AND   A.ACTION_CODE  = ''Receipt''
            AND   A.EMPLOYEE_ID = B.ACC_NUM
            AND   B.ACC_NUM = E.ACC_NUM
            AND   C.DEBIT_CARD_POSTED = ''N''
            AND   C.ACC_ID = B.ACC_ID
            AND   D.PERS_ID = B.PERS_ID
            AND   B.ACCOUNT_TYPE = ''HSA''
            AND   A.RECORD_TRACKING_NUMBER = C.CHANGE_NUM
            AND   TRUNC(A.CREATION_DATE) = TRUNC(SYSDATE)   ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hsa_email||','||g_cc_email||',cindy.carrillo@sterlingadministration.com'
                           ,'hsa_receipt_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HSA Receipt Posting Errors in BPS for '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hsa_receipt_error;

PROCEDURE email_annual_election_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Annual election Differences Between BPS and SAM  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Annual election Differences Between BPS and SAM  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT A.ACC_NUM "Account Number",C.PLAN_TYPE "Plan Type"
                   , C.PLAN_START_DATE "Plan Start Date", C.PLAN_END_DATE "Plan End Date"
                   , A.ANNUAL_ELECTION "BPS Annual Election", C.ANNUAL_ELECTION "Annual election"
                   , PC_ENTRP.GET_ENTRP_NAME(D.ENTRP_ID) "Employer Name"
              FROM   METAVANTE_CARD_BALANCES A
                   , BEN_PLAN_ENROLLMENT_SETUP C
                   , ACCOUNT B
                   , PERSON D
              WHERE  A.ACC_ID = C.ACC_ID
              AND    A.PLAN_TYPE = C.PLAN_TYPE
              AND    A.PLAN_START_DATE = C.PLAN_START_DATE
              AND    B.PERS_ID = D.PERS_ID
              AND    B.ACC_ID= C.ACC_ID
              AND    D.ENTRP_ID <> 7898
              AND    A.PLAN_END_DATE = C.PLAN_END_DATE
              AND    A.ANNUAL_ELECTION <> C.ANNUAL_ELECTION
              AND    C.STATUS = ''A'' AND C.PLAN_END_DATE > ADD_MONTHS(SYSDATE,-6) ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email||','||'VHSTeam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'hrafsa_annual_election_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Annual election Differences Between BPS and SAM '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
END email_annual_election_error;

PROCEDURE email_hrafsa_bal_diff_error
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Balance Differences Between BPS and SAM  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA  Balance Differences Between BPS and SAM  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT  ACC_NUM "Account Number",
                     PLAN_TYPE "Plan Type",
                      to_char(PLAN_START_DATE,''MM/DD/YYYY'') "Plan Start Date",
                      to_char(PLAN_END_DATE,''MM/DD/YYYY'') "Plan End Date",
                     DISBURSABLE_BALANCE "Balance in BPS",
                     SAM_BAL "Balance in SAM",
                     PC_ENTRP.GET_ENTRP_NAME(entrp_id) "Employer Name"
              FROM  BPS_SAM_BALANCES  WHERE bal_dff <> 0
              AND  PLAN_END_DATE > ADD_MONTHS(SYSDATE,-6) ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                          ,'VHSTeam@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com'
                           ,'hrafsa_bal_diff_errors'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA  Balance Differences Between BPS and SAM '||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hrafsa_bal_diff_error;

PROCEDURE send_nightly_notification
  IS
  BEGIN

   -- MOVED all the notifications to PC_NIGHTLY_EMAIL
   null;
   /* dbms_output.put_line('HRA/FSA address changes error');
    email_hrafsa_address_error;
    dbms_output.put_line('HRA/FSA dependent card  error');
    email_hrafsa_dep_card_error;
    dbms_output.put_line('HSA address error');

    email_hsa_address_error;
    dbms_output.put_line('HSA dependent creation error');

    email_hsa_dep_card_error;
   dbms_output.put_line('HSA annual election changes error');

    email_annual_election_error;
    dbms_output.put_line('Employer setup fee of $35');

    employer_setup_fee;
    dbms_output.put_line('Claims with deductible report');

    email_hrafsa_deductible;
    dbms_output.put_line('Incomplete accounts in HSA');

    email_hsa_incomplete_accounts;
    dbms_output.put_line('Duplicate epayments in HSA');

    send_email_duplicate_epayment;
    dbms_output.put_line('Non Discrimination notification');

    non_discrim_notification;
    dbms_output.put_line('Plan Renewal Notification');

    plan_renewal_notification;
    dbms_output.put_line('Claim Deny Notification');

    process_deny_notification;
    dbms_output.put_line('OFAC results Notification');


    notify_hsa_ee_incomplete;
    dbms_output.put_line('Closed HSA account reactivation');

    closed_account_reactivation;
    dbms_output.put_line('List bill posted notification to ER');

    notify_er_check_posted;
    dbms_output.put_line('Error Accounts in HSA');


    pc_nightly_email.pending_accounts;
    dbms_output.put_line('Fees problem in HSA');

    pc_nightly_email.fee_problem;
    dbms_output.put_line('Claim Fees problem in HSA');

    pc_nightly_email.claim_fee_problem;
    dbms_output.put_line('Closed Account with fee bucket balance in HSA');

    pc_nightly_email.fee_bucket_close_acc;
    dbms_output.put_line('Unpaid HSA accounts to sales rep');

    pc_nightly_email.unpaid_sales_accounts;
    dbms_output.put_line('Suspended accounts ');

    suspended_60days_notification;
    dbms_output.put_line('Catchup with 55 year old ');
    email_unsubstantiated_txn;

    catchup_55_notification;
   send_email_on_ofac_results;
    dbms_output.put_line('ID Verification results Notification');

    send_email_on_id_results;
    dbms_output.put_line('Employee Notification on incomplete HSA account');
    email_duplicate_claims;

    email_enrollment_report;
    email_er_enrollment_report;
    email_ach_not_released;
 --   email_sam_report;
    ach_duplicate_report;
    enrollments_audit_report;
    process_sfo_notifications;
    email_renewal_report;
    hrafsa_negative_balance_report;
    email_hrafsa_bal_diff_error;
    pc_nightly_email.email_Sam_Users;

    email_hrafsa_payment_error;
    notify_claim_after_plan_yr;
    notify_claim_before_plan_yr;
    notify_service_after_plan_yr;
    notify_no_plan_yr;
    email_sf_ord_term_rep;
    send_email_on_bellarmine;
    notify_takeover;
    email_hrafsa_enrollments;
    notify_fraud;
    notify_see_change_er_details;
    Email_Rate_Plan_Details;
    email_invoice_report_details;
    catchup_65_notification;
    Email_Pop_Renewals_Details;
    email_multi_product_client;
    hrafsa_approval_report;
    compliance_payment_report;
    hrafsa_ae_change_report;
    Email_FSA_EE_with_COBRA;
    notify_eob_claims;
    notify_comp_discrim_testing;
    process_qe_approval;
    process_new_ben_plans;
    List_pending_claims;
  --  email_suspended_cards;
    pc_nightly_email.EMAIL_VOID_INVOICES;
  --  notify_pending_approvals;
 --   Notify_acct_termination;*/
END send_nightly_notification;

PROCEDURE send_email_duplicate_epayment
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Duplicate ePayments </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>uplicate ePayments </p>
       </table>
        </body>
        </html>';
    l_sql := 'select count(*), claimn_id, c.acc_num
        from  payment a, claimn b, account c
        where reason_code = 19
        and   a.acc_id = c.acc_id
        and   a.claimn_id = b.claim_id
        and   b.claim_pending < 0
         group by  claimn_id, c.acc_num, a.amount
        having count(*) > 1';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com,'||
                            'techlog@sterlingadministration.com'
                           ,'duplicate_epayment'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Duplicate ePayments on'||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_duplicate_epayment;
PROCEDURE closed_account_reactivation
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Closed Accounts Requested for Reopening </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Closed Accounts Requested for Reopening </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT B.FIRST_NAME "First Name"
              ,  B.LAST_NAME  "Last Name"
              ,  B.MIDDLE_NAME "Middle Name"
              ,  C.ACC_NUM "Account Number"
              ,  TO_CHAR(DECODE(INSTR(B.START_DATE,''/''),0,
                     to_date(B.START_DATE,''MMDDRRRR'')
                    ,to_date(B.START_DATE,''MM/DD/RRRR'')),''MM/DD/YYYY'') "Effective Date"
              ,  B.EMPLOYER_NAME "Employer Name"
           FROM   PERSON A, MASS_ENROLLMENTS_EXTERNAL B, ACCOUNT C, INSURE D
           WHERE  B.SSN = REPLACE(A.SSN,''-'')
        AND   A.PERSON_TYPE = ''SUBSCRIBER''
        AND   C.PERS_ID = A.PERS_ID
        AND   D.PERS_ID = A.PERS_ID
        AND   C.ACCOUNT_STATUS = 4
        AND   NVL(FORMAT_TO_DATE(B.START_DATE),SYSDATE) > SYSDATE
        AND   D.END_DATE IS NULL';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com,'||
                            'techlog@sterlingadministration.com'
                           ,'closed_account_reopen'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Closed Accounts Requested for Reopening '||to_char(sysdate,'MM/DD/YYYY'));
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 END closed_account_reactivation;

 PROCEDURE employer_setup_fee
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Active Employer with Setup Fee more than $25 </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Active Employer with Setup Fee more than $25  </p>
       </table>
        </body>
        </html>';
       l_sql := 'SELECT B.NAME "Name"
                     ,  A.ACC_NUM  "Account Number"
                     ,  A.FEE_SETUP "Setup Fee"
                 FROM   ENTERPRISE B, ACCOUNT A
                 WHERE  B.ENTRP_ID = A.ENTRP_ID
                   AND  A.END_DATE IS NULL
                 AND A.FEE_SETUP > 25
                 AND A.ACCOUNT_TYPE = ''HSA'' ';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'dana.ramos@sterlingadministration.com,'||
                           'cindy.carillo@sterlingadministration.com,'||
                           'shavee.kapoor@sterlingadministration.com,'||
                            'techlog@sterlingadministration.com'
                           ,'active_employer_account_more_than_25'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Active Employer with Setup Fee more than $25 as of '||to_char(sysdate,'MM/DD/YYYY'));
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 END employer_setup_fee;

 PROCEDURE notify_er_check_posted
IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  l_process      VARCHAR2(1) := 'N';
  l_cc_address   VARCHAR2(255);
  l_template_subject VARCHAR2(4000);
  l_template_body  VARCHAR2(32000);
  l_content        VARCHAR2(32000);
  l_to_address   VARCHAR2(255);
  l_tab   VARCHAR2_4000_TBL := VARCHAR2_4000_TBL();
   num_tbl number_tbl;


BEGIN
    --   pc_log.log_error('PC_CLAIM.audit_review_notification','p_payment_register_id '||p_payment_register_id );

  get_template_body('ER_HSA_LIST_BILL_CHECK_POSTED',l_template_subject,l_template_body,l_cc_address,l_to_address);

  FOR X IN ( SELECT  name
                  ,  check_number
                      ,  format_money(check_amount) check_amount
                  ,  check_date
                  ,  entrp_contact
                      ,  entrp_email
                      ,  acc_id
               FROM  er_check_post_notify_v
               WHERE ROWNUM < 4 AND ENTRP_EMAIL IS NOT NULL)
   LOOP

            l_content := null;
         l_tab :=  in_list(X.entrp_email,',');
      pc_log.log_error('notify_er_check_posted','beginning');

        FOR i IN 1 .. l_tab.COUNT
        LOOP

                 PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
                ,P_TO_ADDRESS   => l_tab(i)
                ,P_CC_ADDRESS   => l_cc_address
                ,P_SUBJECT      =>  l_template_subject
                --,P_SUBJECT      => l_template_subject
                ,P_MESSAGE_BODY => l_template_body
                ,P_ACC_ID       => x.acc_id
                ,P_USER_ID      => 0
                ,X_NOTIFICATION_ID => l_notif_id );

                select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
                (select replace(ssn,'-')from person where pers_id=pc_person.pers_id_from_acc_id(x.acc_id));
                add_notify_users(num_tbl,l_notif_id);

                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',x.entrp_contact,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('CHECK_AMOUNT',x.check_amount,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('CHECK_NUMBER',x.check_number,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('CHECK_DATE',x.check_date,l_notif_id);

                 UPDATE EMAIL_NOTIFICATIONS
                  SET    MAIL_STATUS = 'READY'
                 WHERE  NOTIFICATION_ID  = l_notif_id;
           END LOOP;
    END LOOP;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_er_check_posted;
 PROCEDURE notify_hsa_ee_incomplete
IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  l_process      VARCHAR2(1) := 'N';
  l_cc_address   VARCHAR2(255);
  l_template_subject VARCHAR2(4000);
  l_template_body  VARCHAR2(32000);
  l_content        VARCHAR2(32000);
  l_to_address     VARCHAR2(255);
  r                RAW(32767);
  l_enroll_link    VARCHAR2(32000);
  num_tbl number_tbl;

BEGIN
    --   pc_log.log_error('PC_CLAIM.audit_review_notification','p_payment_register_id '||p_payment_register_id );

  get_template_body('HSA_EE_INCOMPLETE_APP_NOTICE',l_template_subject,l_template_body,l_cc_address,l_to_address);

  FOR X IN ( SELECT  name
      ,  enrollment_id
          ,  user_name
      ,  to_char(reg_date,'MM/DD/YYYY') reg_date
      ,  employer_name
          ,  confirmed
          ,  registered
          ,    email
          ,  acc_id
          ,  acc_num
      FROM  ee_hsa_incomplete_app_v
        WHERE   (NVL(registered,'N') = 'N' OR NVL(confirmed,'N') = 'N') )
   LOOP

            l_content := null;

                 PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
                ,P_TO_ADDRESS   => x.email
                ,P_CC_ADDRESS   => l_cc_address
                ,P_SUBJECT      =>  l_template_subject
                ,P_MESSAGE_BODY => l_template_body
                ,P_ACC_ID       => x.acc_id
                ,P_USER_ID      => 0
                ,X_NOTIFICATION_ID => l_notif_id );

               select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
                (select replace(ssn,'-')from person where pers_id=pc_person.pers_id_from_acc_id(x.acc_id));
                add_notify_users(num_tbl,l_notif_id);


                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',x.employer_name,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_NAME',x.name,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('DATA_ENTRY_DATE',x.reg_date,l_notif_id);

                     UPDATE EMAIL_NOTIFICATIONS
                  SET    MAIL_STATUS = 'READY'
                 WHERE  NOTIFICATION_ID  = l_notif_id;
    END LOOP;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_hsa_ee_incomplete;
 PROCEDURE email_hsa_incomplete_accounts
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HSA Incomplete Accounts  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HSA Incomplete Accounts  </p>
       </table>
        </body>
        </html>';


   l_sql := 'Select First_Name "First Name",Last_Name "Last Name",Employer_Name "Employer Name",Acc_Num "Account Number"
            ,To_Char(Start_Date,''mm/Dd/Yyyy'')"Effective Date"
             ,Data_Entry_Date "Data entry Date",Refund_Amount "Total funded Amount"
             ,SALES_REP "Sales Rep"
             ,ACCOUNT_MANAGER "Account Manager"
             ,COMPLETE_FLAG "Setup Status"
              FROM Incomplete_Account_Funds_V
              WHERE 1 = 1';



 Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                          ,g_hsa_email||','||g_cc_email||','||pc_notifications.get_dept_email('6')||','||'accountrepresentatives@sterlingadministration.com'
                            ,'hsa_incomplete_accounts'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HSA Incomplete Accounts '||to_char(sysdate,'MM/DD/YYYY'));



 --  END IF;
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_hsa_incomplete_accounts;
PROCEDURE email_online_incomplete_app
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title> Online Incomplete Applications  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Online Incomplete Applications  </p>
       </table>
        </body>
        </html>';


   l_sql := 'Select A.Name "Employer Name",B.Acc_Num "Account Number"
            ,To_Char(B.Start_Date,''MM/DD/YYYY'')"Effective Date"
             ,To_Char(B.Creation_Date,''MM/DD/YYYY'') "Data entry Date"
             ,B.Account_Type "Account Type"
             ,B.Enrollment_Source "Source"
             ,A.Address "Address"
             ,A.city "City"
             ,A.State "State"
             ,A.ENTRP_Email "Email"
             from Enterprise A, Account B
             Where b.enrollment_source=''ONLINE''
             AND A.entrp_id=B.Entrp_id
             And b.Complete_flag=0
             AND B.Decline_Date is Null';


 Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                             ,g_cc_email||','||pc_notifications.get_dept_email('6')||','||pc_notifications.get_dept_email('81')||','||'Duarte.Batista@sterlingadministration.com,Dana.Ramos@sterlingadministration.com'
                             --,'Duarte.Batista@sterlingadministration.com'
                              ,'Online_Incomplete_Applications'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Incomplete Online Employer Applications '||to_char(sysdate,'MM/DD/YYYY'));



 --  END IF;
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_online_incomplete_app;

PROCEDURE email_closed_opportunities
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title> Closed Opportunities  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Closed Opportuniites </p>
       </table>
        </body>
        </html>';


   l_sql := 'select "opportunity_name"@sugarprod as "Name" ,"acc_num_c"@sugarprod as "Account Number","sales_stage"@sugarprod as "Sales Stage",
           "opportunity_type"@sugarprod,pc_sales_team.get_sales_rep_name("account_manager_c"@sugarprod)as "Account Manager",
         "date_closed"@sugarprod as " Date Closed" from "opportunities_v"@sugarprod where "date_closed"@sugarprod >= SYSDATE-90 AND "date_closed"@sugarprod <= SYSDATE
        and  "sales_stage"@sugarprod like ''%Complete'' and  "opportunity_type"@sugarprod=''New Business''';


 Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                            ,'shavee.kapoor@sterlingadministration.com'
                           -- ,'accountmanagement@sterlingadministration.com'
                              ,'Closed Opportunities'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Closed Opportunities '||to_char(sysdate,'MM/DD/YYYY'));



 --  END IF;
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_closed_opportunities;


PROCEDURE email_sales_leads
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title> Leads Created by Sales  </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Leads Created By sales </p>
       </table>
        </body>
        </html>';


   l_sql := 'select * from sales_lead_cnt_v where 1=1 ';

dbms_output.put_line('sql '||l_sql);

 Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                            ,'shavee.kapoor@sterlingadministration.com,Duarte.Batista@sterlingadministration.com,sales@sterlingadministration.com'
                           -- ,'accountmanagement@sterlingadministration.com'
                              ,'Leads By Sales'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Leads Created By Sales '||to_char(sysdate,'MM/DD/YYYY'));



 --  END IF;
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_sales_leads;
PROCEDURE email_duplicate_claims
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Possible Duplicate Claims with claims in Pending Review Status </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Possible Duplicate Claims with claims in Pending Review Status   </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT ACC_NUM, CLAIM_ID, DUPLICATE_CLAIM
        FROM (SELECT C.ACC_NUM, A.CLAIM_ID, PC_CLAIM.IS_DUPLICATE_CLAIM(A.CLAIM_ID) DUPLICATE_CLAIM
        FROM   claimn a, account C
        WHERE  A.PERS_ID = C.PERS_ID
        AND    A.CLAIM_STATUS = ''PENDING_REVIEW'')
        WHERE DUPLICATE_CLAIM IS NOT NULL ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email
                           ,'hrafsa_duplicate_claims'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Duplicate Claims on'||to_char(sysdate,'MM/DD/YYYY'));
 --  END IF;
    exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
end EMAIL_DUPLICATE_CLAIMS;
  PROCEDURE sfo_letter_notification
 (p_pers_id              IN NUMBER
 ,p_acc_id               IN NUMBER
 ,p_letter_type          IN VARCHAR2
 ,p_user_id              IN NUMBER
 )
 IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  num_tbl number_tbl;
BEGIN

   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
              AND     TEMPLATE_NAME= DECODE(p_letter_type, 'TERMINATION','HRA_SEPARATION_NOTICE'
                                                     , 'QUARTERLY','HRA_SFO_QUARTERLY_STATEMENT')
              AND     STATUS = 'A')
   LOOP
   FOR XX IN (SELECT email, first_name||' '||middle_name||' '||last_name name FROM person
               WHERE  pers_id = p_pers_id)
   LOOP
     IF xx.email IS NOT NULL THEN
         PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
         (P_FROM_ADDRESS => 'benefits@sterlingadministration.com'
         ,P_TO_ADDRESS   => xx.email
         ,P_CC_ADDRESS   => x.cc_address
         ,P_SUBJECT      => x.template_subject
         ,P_MESSAGE_BODY => x.template_body
         ,P_ACC_ID       => p_acc_id
         ,P_USER_ID      => p_user_id
         ,X_NOTIFICATION_ID => l_notif_id );
        num_tbl(1):=p_user_id;
         add_notify_users(num_tbl,l_notif_id);

         PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',xx.name,l_notif_id);
     END IF;
   END LOOP;

       UPDATE EMAIL_NOTIFICATIONS
       SET    MAIL_STATUS = 'READY'
          ,   ACC_ID = p_acc_id
       WHERE  NOTIFICATION_ID  = l_notif_id;
   END LOOP;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END sfo_letter_notification;

-- in terminate_plans procedure added this piece of code

 --Nightly batch to process the Quarterly and Seperation for SFO ordinance

 PROCEDURE process_sfo_notifications
 IS
 begin
   FOR X IN ( SELECT pers_id,ben_plan_id,acc_id,letter_type FROM SUBSCRIBER_SFO_QTRLY_V
               UNION
               SELECT pers_id,ben_plan_id,acc_id,letter_type FROM SUBSCRIBER_SFO_TERM_V)
    LOOP
         sfo_letter_notification(x.pers_id,x.acc_id,x.letter_type,0);
    end LOOP;
    null;
  END process_sfo_notifications;

  FUNCTION get_dept_email (p_dept_id IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_email_address VARCHAR2(3200);
  BEGIN
           select  -- wm_concat(email)                                --  Commented BY RPRABU 17/10/2017
                  -- LISTAGG(email, ',') WITHIN GROUP (ORDER BY email)  --- Added by RPRABU on 17/10/2017
				 LISTAGG(distinct(decode(is_valid_email(email),'Y',email,null)) , ',') WITHIN GROUP (ORDER BY email) -- commented above and added by Joshi for 12716. ignore invalid address. 
            into    l_email_address
            from   employee
            where  dept_no = p_dept_id
            and term_date is null;
     return l_email_address;
  EXCEPTION
     WHEN OTHERS THEN
       RETURN 'customer.service@sterlingadministration.com,'||g_hrafsa_cc_email;
  END get_dept_email;
PROCEDURE email_er_enrollment_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_count          NUMBER := 0;
BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<br/><br/>
       <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
            <caption>Daily employer enrollment report</caption>
            <tr>
              <th width=\"21%\">Employer Name</th>
              <th width=\"21%\">Number of Employees</th>
              <th width=\"21%\">Employer location </th>
              <th width=\"21%\">Product Line</th>
              <th width=\"21%\">Broker Name</th>
              <th width=\"21%\">SalesDirector Name</th>
               <th width=\"21%\">AccountManager Name</th>
               <th width=\"21%\">Enrollment Source</th>
             </tr>';



  FOR X IN (Select  name, pc_entrp.count_active_person(e.entrp_id,a.account_type) no_of_employees
               ,    e.city ||' '||e.state location
               ,    a.account_type
               ,    pc_broker.get_broker_name(a.broker_id) broker_name
               ,   pc_account.get_salesrep_name(a.salesrep_id) salesrep_name
               ,   pc_account.get_salesrep_name(a.am_id) account_Manager
               ,   a.enrollment_source
            FROM   enterprise e, account a
            where  e.entrp_id = a.entrp_id
            and trunc(a.creation_date) = trunc(sysdate-1))
  LOOP
   l_count := l_count+1;
   l_html_message  :=  l_html_message ||' <tr><td> '||x.name
              ||'</td><td>'||x.no_of_employees||'</td><td>'
              ||x.location||'</td><td>'
              ||x.account_type||'</td><td>'
              ||x.broker_name||'</td><td>'
              ||x.salesrep_name||'</td><td>'
              ||x.account_Manager||'</td><td>'
              ||x.enrollment_source||'</td><td>
               </tr><tr></tr><br/>';
  END LOOP;
  IF l_count > 0 THEN
    l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);
    FOR X IN ( SELECT email FROM employee WHERE dept_no in ('1','3','5','7','21','6','41','81')
               and term_date is null and email is not null
            )
    LOOP
        Mail_Utility.html_email(x.email
                            ,'oracle@sterlingadministration.com'
                             ,'Daily Employer Enrollment Report'||to_char(sysdate,'MM/DD/YYYY')
                             , 'test'
                             ,l_html_message);

    END LOOP;
  END IF;
 --  END IF;
  exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_er_enrollment_report;
PROCEDURE email_enrollment_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_count          NUMBER := 0;

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN


    l_html_message  := '<br/><br/>
       <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
            <caption>Daily Plan Enrollment report</caption>
            <tr>
              <th>Name</th>
              <th>Employer Name</th>
              <th>Account Number</th>
              <th>Plan Type</th>
              <th>Plan Start Date</th>
              <th>Plan End Date</th>
              <th>Creation Date</th>
              <th>Action</th>
             </tr>';


         FOR X IN (Select E.First_Name ||' '||E.Last_Name Name
                     ,A.Acc_Num
                   ,C.Plan_Type
                   ,pc_entrp.get_entrp_name(e.entrp_id) employer_name
                   ,to_char(C.Plan_Start_Date,'mm/dd/yyyy') Plan_Start_Date
                   ,to_char(C.Plan_End_Date,'mm/dd/yyyy') Plan_End_Date
                   ,to_char(C.Creation_Date,'mm/dd/yyyy') Creation_Date
                                     ,decode(b.action,'N','Enrollment'
                                   ,'R','Renewal'
                       ,'C','Demographic Change'
                       ,'T','Termination'
                       ,'A','Annual Election Change') action
            From Account A, Online_Enroll_Plans B, Ben_Plan_Enrollment_Setup C,Online_Enrollment E
            Where c.ben_plan_Id_main = b.er_ben_plan_id
            And A.Account_Type In ('HRA','FSA')
            And  C.Acc_Id = A.Acc_Id
            And B.Enrollment_Id = E.Enrollment_Id
            And A.Acc_Id = E.Acc_Id
        AND C.STATUS IN ('A','I')
            and trunc(c.creation_date) = trunc(sysdate-1))
     LOOP
           l_count := l_count+1;
           l_html_message  :=  l_html_message ||' <tr><td> '||x.name
              ||'</td><td>'
              ||x.employer_name||'</td><td>'
              ||x.Acc_Num||'</td><td>'
              ||x.Plan_Type||'</td><td>'
              ||x.Plan_Start_Date||'</td><td>'
              ||x.Plan_End_Date||'</td><td>'
              ||x.Creation_Date||'</td><td>'
              ||x.action||'</td><td>'
              ||'</tr><tr></tr><br/>';

     END LOOP;
   IF l_count > 0 THEN
         l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);

        FOR X IN ( SELECT email FROM employee WHERE dept_no = '2'
                   and term_date is null and email is not null
                   union
                   select 'techlog@sterlingadministration.com' from dual
                   union
                   select 'VHSTeam@sterlingadministration.com' from dual
                )
        LOOP
         Mail_Utility.html_email( X.EMAIL
                                 ,'oracle@sterlingadministration.com'
                                 , 'Daily HRA/FSA Online Plan Upload Report '||to_char(sysdate,'MM/DD/YYYY')
                                , 'test'
                                 , l_html_message);

        END LOOP;
   END IF;
  exception
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 --  END IF;
END email_enrollment_report;

-- NOT USED
PROCEDURE email_ach_not_released
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>ACH Payments</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>ACH Payments not released today </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT to_char(transaction_date) "Transaction Date"
          ,  acc_num  "Account Number"
          ,  total_amount "Total Amount"
              FROM   ACH_TRANSFER_V  WHERE transaction_date < TRUNC(SYSDATE)
          AND    status IN (1,2) and transaction_type = ''D'' ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           , g_cc_email
                           ,'ach_payment_delay'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'ACH Payments not released on '||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END email_ach_not_released;
PROCEDURE ach_duplicate_report
AS
  l_email   VARCHAR2(3200);
  l_html_message   VARCHAR2(32000);

  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>ACH Duplicates (Potential)</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>ACH Duplicates (Potential)</p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT acc_num "Account Number",COUNT(*) "No of duplicates", ''Claim'' "Transaction Type"
                     , to_char(transaction_date,''MM/DD/YYYY'') "Transaction Date"
                     , total_amount "Total amount"
              FROM   ach_transfer_v
              WHERE  status in (1,2)
              AND    transaction_date > trunc(sysdate)
              and    claim_id IS not NULL
              GROUP  BY acc_num, transaction_date, total_amount,claim_id
              HAVING COUNT(*) > 1
              UNION
              SELECT acc_num,COUNT(*) no_of_txns, ''Invoice'' transaction_type, to_char(transaction_date,''MM/DD/YYYY'') transaction_date, total_amount
              FROM   ach_transfer_v
              WHERE  status in (1,2)
              AND    transaction_date > trunc(sysdate)
              and    invoice_id IS not NULL
              GROUP  BY acc_num, transaction_date, total_amount,invoice_id
              HAVING COUNT(*) > 1
              UNION
              SELECT acc_num,COUNT(*) no_of_txns, transaction_type, to_char(transaction_date,''MM/DD/YYYY'') transaction_date, total_amount
              FROM   ach_transfer_v
              WHERE  status in (1,2)
              AND    transaction_date > trunc(sysdate)
              and    invoice_id IS  NULL AND claim_id IS NULL
              GROUP  BY acc_num, transaction_date, total_amount,transaction_type
              HAVING COUNT(*) > 1';

          FOR X IN ( SELECT    ---  wm_concat(email) email   --- Commented by RPRABU 0n 17/10/2017
                          LISTAGG(email, ',') WITHIN GROUP (ORDER BY email)  email -- Added by RPRABU 0n 17/10/2017
                     FROM employee WHERE dept_no in ('8','3')
                   and term_date is null and email is not null
                )
          LOOP
             l_email := x.email;
          end loop;
             mail_utility.report_emails('oracle@sterlingadministration.com'
                                   , l_email||','||g_cc_email
                                   ,'ach_dup_report'||to_char(sysdate,'MMDDYYYY')||'.xls'
                                   , l_sql
                                   , l_html_message
                                   , 'ACH Duplicates '||to_char(sysdate-1,'MM/DD/YYYY'));


 --  END IF;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END ach_duplicate_report;
PROCEDURE hrafsa_negative_balance_report
AS
  l_email   VARCHAR2(3200);
  l_html_message   VARCHAR2(32000);

  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Negative Balance Report</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Negative Balance Report</p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT A.ACC_NUM "Account Number"
          ,PC_ENTRP.GET_ENTRP_NAME(C.ENTRP_ID) "Employer Name"
          ,PC_ACCOUNT.ACC_BALANCE(A.ACC_ID,B.PLAN_START_DATE,B.PLAN_END_DATE,A.ACCOUNT_TYPE,B.PLAN_TYPE
                                 ,B.PLAN_START_DATE,B.PLAN_END_DATE) "Account Balance"
         FROM  ACCOUNT A, BEN_PLAN_ENROLLMENT_SETUP B, PERSON C
         WHERE A.ACC_ID = B.ACC_ID
          AND   A.PERS_ID  = C.PERS_ID
          AND   B.PLAN_END_DATE > SYSDATE
        AND   A.ACCOUNT_TYPE IN (''HRA'',''FSA'')
        AND   B.STATUS IN (''A'',''I'')
          AND   PC_ACCOUNT.ACC_BALANCE(A.ACC_ID,B.PLAN_START_DATE,B.PLAN_END_DATE,A.ACCOUNT_TYPE,B.PLAN_TYPE
                     ,B.PLAN_START_DATE,B.PLAN_END_DATE) < 0';

          FOR X IN ( SELECT --- wm_concat(email)||',vijaya.kotipalli@sterlingadministration.com' email commented by rprabu 17/10/2017
                    LISTAGG(email, ',') WITHIN GROUP (ORDER BY email) ||',Sumithra.Bai@sterlingadministration.com'  email -- Added by rprabu 17/10/2017--Updated by sk on 05/27/2021
                   FROM employee WHERE dept_no = '2'
                   and term_date is null and email is not null
                )
          LOOP
             l_email := x.email;
          end loop;
          mail_utility.report_emails('oracle@sterlingadministration.com'
                                   , l_email||','||g_cc_email
                                   ,'negative_balance_report'||to_char(sysdate,'MMDDYYYY')||'.xls'
                                   , l_sql
                                   , l_html_message
                                   , 'Negative Balance '||to_char(sysdate-1,'MM/DD/YYYY'));


 --  END IF;
   exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END hrafsa_negative_balance_report;
PROCEDURE enrollments_audit_report
AS
  l_email   VARCHAR2(3200);
  l_html_message   VARCHAR2(32000);
  l_count  NUMBER := 0;
  l_sql            VARCHAR2(32000);

BEGIN


    l_html_message  := '<br/><br/>
       <table  cellpadding=\"0\" cellspacing=\"0\">
            <caption>Enrollment Audit Report</caption>
            <tr>
              <th width=\"21%\">Account Number</th>
              <th width=\"21%\">First Name</th>
              <th width=\"21%\">Last Name</th>
              <th width=\"21%\">Address</th>
              <th width=\"21%\">City</th>
              <th width=\"21%\">State</th>
              <th width=\"21%\">Zip</th>
              <th width=\"21%\">Birth Date</th>
              <th width=\"21%\">ID Number</th>
              <th width=\"21%\">Error</th>
             </tr>';

      FOR X IN ( SELECT b.acc_num,a.first_name, a.last_name, a.address,a.city,a.state,a.zip,a.birth_date,  NVL(a.driver_license,a.passport) IDNUMBER
               ,decode(error_message,'Successfully Loaded',null,error_message) error_message
                FROM mass_enrollments a, account b, person c
                where a.mass_enrollment_id = c.mass_enrollment_id(+)
                and   c.pers_id  = b.pers_id(+)
                and   a.created_by in (2541,2542)
                and   a.creation_date > sysdate-1
                union
                SELECT b.acc_num,a.first_name, a.last_name, a.address,a.city,a.state,a.zip,to_char(a.birth_date,'MMDDYYYY'),
                NVL(a.drivlic,a.passport) IDNUMBER
                   ,null
                FROM person a, account b
                where  a.pers_id  = b.pers_id
                and   b.created_by in (2541,2542)
                and   b.creation_date > sysdate-1 )
      LOOP
         l_count := l_count+1;
         l_html_message  :=  l_html_message ||' <tr><td> '||x.acc_num
              ||'</td><td>'||x.first_name||'</td><td>'
              ||x.last_name||'</td><td>'
              ||x.address||'</td><td>'
              ||x.city||'</td><td>'
              ||x.state||'</td><td>'
              ||x.zip||'</td><td>'
              ||x.birth_date||'</td><td>'
              ||x.IDNUMBER||'</td><td>'
               ||x.error_message||'</td><td>' ||
              ' </tr><tr></tr><br/>';
      END LOOP;

     IF l_count > 0 THEN
       l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);

       for x in ( SELECT * FROM employee WHERE dept_no = '5'
                   and term_date is null and email is not null)
       loop
           Mail_Utility.html_email( x.email
                            ,'sam@sterlingadministration.com'
                            ,'Enrollments Audit Report ('||to_char(sysdate,'MM/DD/YYYY')||')'
                            , 'test'
                            ,l_html_message);

       end loop;

     END IF;
     exception
       WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END enrollments_audit_report;
 PROCEDURE hrafsa_future_claim_notify
  (p_claim_id             IN NUMBER)  IS

    l_message_body VARCHAR2(4000);
    l_notif_id     NUMBER;
    l_return_status VARCHAR2(255) := 'S';
    l_error_message VARCHAR2(255);
    num_tbl number_tbl;
  BEGIN


    FOR X IN (SELECT P.FIRST_NAME||' '||P.LAST_NAME NAME
             , to_char(SYSDATE,'MM/DD/YYYY') TODAY_DATE
             , A.ACC_NUM
             , PC_ENTRP.GET_ENTRP_NAME(P.ENTRP_ID) EMP_NAME
             , C.CLAIM_ID
             , C.CLAIM_AMOUNT
             , C.SERVICE_TYPE
             , NVL(PC_USERS.get_email(A.ACC_NUM,A.ACC_ID,P.PERS_ID),p.email) email
             , A.ACC_ID
         , A.PERS_ID
        FROM   CLAIMN C, PERSON P, ACCOUNT A
        WHERE  C.CLAIM_ID = P_CLAIM_ID
        AND    C.PERS_ID = P.PERS_ID
        AND    A.PERS_ID = p.PERS_ID)
    LOOP
      IF x.email IS NOT NULL THEN

         FOR xX IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
              AND    EVENT = 'DISBURSEMENT'
              AND    TEMPLATE_NAME = 'HRAFSA_FUTURE_CLAIM'
              AND    STATUS = 'A')
           LOOP


               PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
               (P_FROM_ADDRESS => 'benefits@sterlingadministration.com'
               ,P_TO_ADDRESS   => x.email
               ,P_CC_ADDRESS   => xx.cc_address
               ,P_SUBJECT      => xx.template_subject
               ,P_MESSAGE_BODY => xx.template_body
               ,P_USER_ID      => 0
               ,P_ACC_ID       => null
               ,X_NOTIFICATION_ID => l_notif_id );
            END LOOP;
           PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',x.NAME,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('DATE',x.TODAY_DATE,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',x.ACC_NUM,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',x.EMP_NAME,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_ID',x.CLAIM_ID,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT',x.CLAIM_AMOUNT,l_notif_id);
           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',x.SERVICE_TYPE,l_notif_id);

           select user_id bulk collect into num_tbl from online_users where replace(tax_id,'-')=
                     (select replace(ssn,'-')from person where pers_id=x.pers_id);
           add_notify_users(num_tbl,l_notif_id);

          UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
                 ,  acc_id = x.acc_id
          WHERE  NOTIFICATION_ID  = l_notif_id;
      ELSE
        INSERT_EVENT_NOTIFICATIONS
             (P_EVENT_NAME   => 'HRAFSA_FUTURE_CLAIM'
             ,P_EVENT_TYPE   => 'PAPER'
             ,P_EVENT_DESC   => 'HRA/FSA Future Claim for '||x.acc_num
             ,P_ENTITY_TYPE  => 'CLAIMN'
             ,P_ENTITY_ID    => x.claim_id
             ,P_ACC_ID       => x.acc_id
             ,P_ACC_NUM      => x.acc_num
             ,P_PERS_ID      => x.pers_id
             ,P_USER_ID      => 0
             ,P_EMAIL        => null
             ,P_TEMPLATE_NAME => null
             ,X_RETURN_STATUS => l_return_status
             ,X_ERROR_MESSAGE => l_error_message);
      END IF;
    END LOOP;
    exception
      WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END hrafsa_future_claim_notify;
  PROCEDURE email_sam_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_count          NUMBER := 0;
BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<br/><br/>
       <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
            <caption>Daily SAM User Login report</caption>
            <tr>
              <th width=\"21%\">SAM User Name</th>
              <th width=\"21%\">Number of Hours in SAM</th>
              <th width=\"21%\">Logged in at </th>
              <th width=\"21%\">Logged out at</th>
             </tr>';



  FOR X IN (Select APEX_USER,NO_OF_HOURS_IN_SAM,FIRST_LOGIN,LAST_LOGIN
            FROM   SAM_LOGIN_SUMMARY_V)
  LOOP
   l_count := l_count+1;
   l_html_message  :=  l_html_message ||' <tr><td> '||x.APEX_USER
              ||'</td><td>'||x.NO_OF_HOURS_IN_SAM||'</td><td>'
              ||x.FIRST_LOGIN||'</td><td>'
              ||x.LAST_LOGIN||'</td>'||
              ' </tr><tr></tr><br/>';
  END LOOP;
  IF l_count > 0 THEN
    l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);

    Mail_Utility.html_email('shavee.kapoor@sterlingadministration.com'
                            ,'sam@sterlingadministration.com'
                            ,'Daily SAM User Login Report(executive)('||to_char(sysdate,'MM/DD/YYYY')||')'
                            , 'test'
                            ,l_html_message);

     Mail_Utility.html_email('techlog@sterlingadministration.com'
                            ,'sam@sterlingadministration.com'
                            ,'Daily SAM User Login Report ('||to_char(sysdate,'MM/DD/YYYY')||')'
                            , 'test'
                            ,l_html_message);

   END IF;
   exception
     WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 END email_sam_report;

 PROCEDURE hsa_nsf_letter_notification
 (p_claim_id             IN NUMBER
 ,p_letter_type          IN VARCHAR2
 ,p_user_id              IN NUMBER)
 IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  num_tbl        number_tbl;
BEGIN

   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
              AND     TEMPLATE_NAME= DECODE(p_letter_type, 'SUBSCRIBER','HSA_REIMBURSEMENT_INSUFFICIENT_FUND_NOTIFICATION'
                                                     , 'PROVIDER','HSA_PROVIDER_INSUFFICIENT_FUND_NOTIFICATION')
              AND     STATUS = 'A')
   LOOP
   FOR XX IN (SELECT a.email, a.first_name||' '||a.middle_name||' '||a.last_name name
                   , b.claim_id, to_char(b.claim_date,'MM/DD/YYYY') claim_date
                   , FORMAT_MONEY(b.claim_amount) claim_amount
                   , e.acc_id
              FROM person a, claimn b, account e
               WHERE  b.claim_id = p_claim_id
               AND    a.pers_id = b.pers_id
               AND    e.pers_id = a.pers_id)
   LOOP
     IF xx.email IS NOT NULL THEN
         PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
         (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
         ,P_TO_ADDRESS   => xx.email
         ,P_CC_ADDRESS   => x.cc_address
         ,P_SUBJECT      => x.template_subject
         ,P_MESSAGE_BODY => x.template_body
         ,P_ACC_ID       => xx.acc_id
         ,P_USER_ID      => p_user_id
         ,X_NOTIFICATION_ID => l_notif_id );
         num_tbl(1):=p_user_id;
         add_notify_users(num_tbl,l_notif_id);

         l_acc_id := xx.acc_id;
         PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',xx.name,l_notif_id);
         PC_NOTIFICATIONS.SET_TOKEN ('DATE',xx.claim_date,l_notif_id);
         PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_ID',xx.claim_id,l_notif_id);
         PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT',xx.claim_amount,l_notif_id);


     END IF;
   END LOOP;

       UPDATE EMAIL_NOTIFICATIONS
       SET    MAIL_STATUS = 'READY'
          ,   ACC_ID = l_acc_id
       WHERE  NOTIFICATION_ID  = l_notif_id;
   END LOOP;
  exception
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END hsa_nsf_letter_notification;
PROCEDURE send_email_on_5498
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Regenerated 5498 Tax Statements</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Regenerated 5498 Tax Statements</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT B.ACC_NUM, TRUNC(A.FEE_DATE) FEE_DATE
                  , FORMAT_MONEY(NVL( A.AMOUNT,0)+NVL(A.AMOUNT_ADD,0)) CONTRIBUTION_AMOUNT
                  , PC_LOOKUPS.GET_FEE_REASON(A.FEE_CODE) REASON
                  , TRUNC(A.CREATION_DATE) CREATION_DATE, TRUNC(A.LAST_UPDATED_DATE) LAST_UPDATED_DATE
                  , PC_USERS.is_active_user(REPLACE(C.SSN,''-''),''S'') ONLINE_USER
                 FROM  INCOME A, ACCOUNT B, PERSON C
              WHERE    A.ACC_ID = B.ACC_ID
                AND    A.FEE_CODE IN (7,10,130)
                AND    B.PERS_ID = C.PERS_ID
                AND    TRUNC(A.FEE_DATE) BETWEEN TRUNC(TRUNC(SYSDATE,''YYYY'')-1,''YYYY'') AND TRUNC(SYSDATE,''YYYY'')-1
                AND    (TRUNC(A.CREATION_DATE) >= TRUNC(SYSDATE)-1
                OR      TRUNC(A.LAST_UPDATED_DATE) >= TRUNC(SYSDATE)-1)
                UNION
                 SELECT B.ACC_NUM, TRUNC(A.FEE_DATE) FEE_DATE
                  , FORMAT_MONEY(NVL( A.AMOUNT,0)+NVL(A.AMOUNT_ADD,0)) CONTRIBUTION_AMOUNT
                  , PC_LOOKUPS.GET_FEE_REASON(A.FEE_CODE) REASON
                  , TRUNC(A.CREATION_DATE) CREATION_DATE, TRUNC(A.LAST_UPDATED_DATE) LAST_UPDATED_DATE
                  , PC_USERS.is_active_user(REPLACE(C.SSN,''-''),''S'') ONLINE_USER
                 FROM  INCOME A, ACCOUNT B, PERSON C
              WHERE    A.ACC_ID = B.ACC_ID
                AND    B.PERS_ID = C.PERS_ID
                AND    A.FEE_CODE IN (7,10,130)
                AND    TRUNC(A.FEE_DATE) BETWEEN  TRUNC(SYSDATE,''YYYY'') AND SYSDATE
                AND    (TRUNC(A.CREATION_DATE) >= TRUNC(SYSDATE)-1
                OR      TRUNC(A.LAST_UPDATED_DATE) >= TRUNC(SYSDATE)-1) ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'cindy.carrillo@sterlingadministration.com,franco.Espinoza@sterlingadministration.com'
                           ,'5498'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , '5498 Statements regenerated on '||to_char(sysdate,'MM/DD/YYYY'));
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_on_5498;
PROCEDURE email_renewal_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_count          NUMBER := 0;
BEGIN
          -- IF to_char(sysdate,'DD') = '01' THEN
        if  trunc(sysdate) =  last_day(sysdate) then
             l_html_message  := '<br/><br/>
               <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
                    <caption>Monthly employer renewal report</caption>
                    <tr>
                      <th width=\"21%\">Employer Name</th>
                      <th width=\"21%\">Benefit Plan</th>
                      <th width=\"21%\">No of employees renewed</th>
                      <th width=\"21%\">Broker Name</th>
                      <th width=\"21%\">Account Manager</th>
                     </tr>';
        else
            l_html_message  := '<br/><br/>
               <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
                    <caption>Daily Employer Renewal report</caption>
                    <tr>
                      <th width=\"21%\">Employer Name</th>
                      <th width=\"21%\">Benefit Plan</th>
                      <th width=\"21%\">No of employees renewed</th>
                      <th width=\"21%\">Broker Name</th>
                      <th width=\"21%\">Account Manager</th>
                     </tr>';
         end if;


          FOR X IN (Select  name
                       ,    c.plan_type
                       ,    (select count(distinct acc_id) from ben_plan_enrollment_setup
                            where c.ben_plan_id_main = ben_plan_id) no_of_ee
                       ,    pc_broker.get_broker_name(a.broker_id) broker_name
                       ,    pc_account.get_salesrep_name(a.am_id) Account_Manager
                    FROM   enterprise e, account a, ben_plan_enrollment_setup c
                    where  e.entrp_id = a.entrp_id
                    and    a.acc_id = c.acc_id
                    and    exists ( select * from ben_plan_enrollment_setup d where d.acc_id = c.acc_id
                              and d.plan_end_date < c.plan_start_date
                    and c.plan_type = d.plan_type)
                    and trunc(c.creation_date) = trunc(sysdate-1)
                    union
                    Select  name
                       ,    c.plan_type
                       ,    (select count(distinct acc_id) from ben_plan_enrollment_setup
                            where c.ben_plan_id_main = ben_plan_id) no_of_ee
                       ,    pc_broker.get_broker_name(a.broker_id) broker_name
                       ,    pc_account.get_salesrep_name(a.am_id) Account_Manager
                    FROM   enterprise e, account a, ben_plan_enrollment_setup c
                    where  e.entrp_id = a.entrp_id
                    and    a.acc_id = c.acc_id
                    and    exists ( select * from ben_plan_enrollment_setup d where d.acc_id = c.acc_id
                              and d.plan_end_date < c.plan_start_date
                    and c.plan_type = d.plan_type)
                    and trunc(sysdate) =  last_day(sysdate)
                    and trunc(c.creation_date) >=  trunc(sysdate,'MM')
                    AND trunc(c.creation_date)<=  trunc(sysdate)
                    )
          LOOP
           l_count := l_count+1;
           l_html_message  :=  l_html_message ||' <tr><td> '||x.name||'</td><td>'
                       ||x.plan_type||'</td><td>'
                       ||x.no_of_ee||'</td><td>'
                      ||x.broker_name||'</td><td>'
                      ||x.account_manager||'</td><td>
                       </tr><tr></tr><br/>';
          END LOOP;
  IF l_count > 0 THEN
    l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);
    FOR X IN ( SELECT email FROM employee WHERE dept_no in ('3','7','2','6','81')
               and term_date is null and email is not null
            )
    LOOP
        Mail_Utility.html_email(x.email
                            ,'oracle@sterlingadministration.com'
                             ,'Daily employer renewal report'||to_char(sysdate,'MM/DD/YYYY')
                             , 'test'
                             ,l_html_message);

    END LOOP;
  END IF;
 --  END IF;
  exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 END email_renewal_report;
 PROCEDURE debit_letter_notification
 (p_pers_id              IN NUMBER
 ,p_acc_id               IN NUMBER
 ,p_letter_type          IN VARCHAR2
 ,p_user_id              IN NUMBER
 ,p_claim_id             IN NUMBER
 )
 IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  l_prov_name    VARCHAR2(100);
  l_service_date VARCHAR2(100) ;
  l_entrp_name  VARCHAR2(100);
  l_amount      NUMBER(15,2);
  num_tbl number_tbl;
 BEGIN
    FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
              AND     TEMPLATE_NAME= DECODE(p_letter_type, 'FIRST_LETTER','FIRST_LETTER_ADDITIONAL_DOC_REQUIRED'
                                                     , 'SECOND_LETTER','SECOND_LETTER_INSUFFICIENT_DOC_OR_NOT_RECEIVED','LAST_LETTER','LAST_LETTER_DEBIT_CARD_INACTIVE','CLAIM_APPROVAL_LETTER')
              AND     STATUS = 'A')
   LOOP
     FOR XX IN (SELECT first_name||' '||last_name name,address,city,state,zip
                   ,   pc_users.get_email_from_taxid(SSN) email
                from    person
                where pers_id = p_pers_id )

     LOOP
         PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
        (P_FROM_ADDRESS => 'benefits@sterlingadministration.com'
        ,P_TO_ADDRESS   => xx.email
        ,P_CC_ADDRESS   => x.cc_address
        ,P_SUBJECT      => x.template_subject
        ,P_MESSAGE_BODY => x.template_body
        ,P_USER_ID      => p_user_id
        ,X_NOTIFICATION_ID => l_notif_id );

        num_tbl(1):=p_user_id;
        add_notify_users(num_tbl,l_notif_id);

  --     IF p_letter_type = 'FIRST_LETTER' THEN
          SELECT PROV_NAME ,to_char(service_start_date,'mm/dd/yyyy'),b.name,claim_amount
          INTO l_prov_name ,l_service_date,l_entrp_name,l_amount
          FROM CLAIMN a,enterprise b
          WHERE claim_id = p_claim_id
          AND a.entrp_id = b.entrp_id;

--       END IF;

       PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_NAME',xx.name,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('CITY',xx.city,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('STATE',xx.state,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('ZIP_CODE',xx.zip,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('ADDRESS',xx.address,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('CURRENT_DATE',to_char(sysdate,'mm/dd/rrrr'),l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_NUMBER',p_claim_id,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER',l_entrp_name,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('DATE_OF_SERVICE',l_service_date,l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('PROVIDER',REPLACE(l_prov_name,'&'),l_notif_id);
       PC_NOTIFICATIONS.SET_TOKEN ('AMOUNT',l_amount,l_notif_id);


      END LOOP; --End of Person(XX) loop

      UPDATE EMAIL_NOTIFICATIONS
      SET    MAIL_STATUS = 'READY'
         ,   ACC_ID = p_acc_id
      WHERE  NOTIFICATION_ID  = l_notif_id;

   END LOOP;
 exception
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 END debit_letter_notification;
 PROCEDURE email_sf_ord_term_rep
 AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_count          NUMBER := 0;
BEGIN
          -- IF to_char(sysdate,'DD') = '01' THEN
              l_html_message  := '<br/><br/>
               <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
                    <caption>San Francisco Ordinance Terminated Accounts Report</caption>
                    <tr>
                      <th width=\"21%\">Account Number</th>
                      <th width=\"21%\">Termination Date</th>
                      <th width=\"21%\">Termination Request Date</th>
                     </tr>';



          FOR X IN (SELECT acc_num  , to_char(TERMINATION_REQ_DATE,'MM/DD/YYYY')  TERMINATION_REQ_DATE
                   , to_char(termination_date,'MM/DD/YYYY') termination_date
                    FROM SUBSCRIBER_SFO_TERM_V )
          LOOP
           l_count := l_count+1;
           l_html_message  :=  l_html_message ||' <tr><td> '||x.acc_num
                       ||x.termination_date||'</td><td>'
                       ||x.termination_req_date||'</td><td>'
                        ||'</tr><tr></tr><br/>';
          END LOOP;
     IF l_count > 0 THEN
    l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);
   FOR X IN ( SELECT email FROM employee WHERE dept_no in ('2')
               and term_date is null and email is not null
            )
    LOOP
        Mail_Utility.html_email(g_hrafsa_email
                            ,'oracle@sterlingadministration.com'
                             ,'San Francisco Ordinance Termination Report for '||to_char(sysdate,'MM/DD/YYYY')
                             , 'test'
                             ,l_html_message);

    END LOOP;
  END IF;
 exception
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END email_sf_ord_term_rep;
 PROCEDURE email_sf_ord_exp_rep
 AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_count          NUMBER := 0;
BEGIN
          -- IF to_char(sysdate,'DD') = '01' THEN
              l_html_message  := '<br/><br/>
               <table width=\"800\" cellpadding=\"0\" cellspacing=\"0\">
                    <caption>San Francisco Ordinance Expired Funds Report</caption>
                    <tr>
                      <th width=\"21%\">Account Number</th>
                      <th width=\"21%\">Expired Amount</th>
                      <th width=\"21%\">Expiration Date</th>
                     </tr>';



          FOR X IN (SELECT acc_num  , expired_amount
                   , to_char(expiration_date,'MM/DD/YYYY') expiration_date
                    FROM TABLE(pc_reports_pkg.get_hra_sfhso_exp_funds_rep) )
          LOOP
           l_count := l_count+1;
           l_html_message  :=  l_html_message ||' <tr><td> '||x.acc_num
                       ||x.expired_amount||'</td><td>'
                       ||x.expiration_date||'</td><td>'
                        ||'</tr><tr></tr><br/>';
          END LOOP;
     IF l_count > 0 THEN
    l_html_message := replace(g_html_message,'XXXBODYXXX',l_html_message);
   FOR X IN ( SELECT email FROM employee WHERE dept_no in ('2')
               and term_date is null and email is not null
            )
    LOOP
        Mail_Utility.html_email(g_hrafsa_email
                            ,'oracle@sterlingadministration.com'
                             ,'San Francisco Ordinance Expired Funds as of '||to_char(sysdate,'MM/DD/YYYY')
                             , 'test'
                             ,l_html_message);

    END LOOP;

  END IF;
exception
 WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END email_sf_ord_exp_rep;
  PROCEDURE email_unsubstantiated_txn
  IS
  BEGIN
     FOR X IN ( SELECT  a.claim_id
                   , a.claim_date
                   , a.creation_date
                   , b.acc_id
                   , a.pers_id
              FROM   claimn a, account b
             WHERE   unsubstantiated_flag = 'Y'
             AND     a.pers_id = b.pers_id
             AND     b.account_type IN ('HRA','FSA')
             AND     a.creation_date IS NOT NULL
             AND (trunc(sysdate- a.creation_date) = 31 OR trunc(sysdate- a.creation_date) = 46))
    LOOP

    -- Claim is unsubstantiated  for the past 30 days
       IF TRUNC(sysdate-x.creation_date) = 31 THEN
         PC_NOTIFICATIONS.debit_letter_notification(x.PERS_ID
                                   ,x.acc_id
                                  ,'SECOND_LETTER'
                           ,0      --System User ID
                         ,x.claim_id);
        END IF;
     -- Claim is unsubstantiated  for the past 45 days
        IF (TRUNC(sysdate-x.creation_date) = 46 )
        THEN
         PC_NOTIFICATIONS.debit_letter_notification(x.PERS_ID
                                   ,x.acc_id
                                  ,'LAST_LETTER'
                           ,0      --System User ID
                         ,x.claim_id);

         pc_log.log_error('Notification',X.pers_id);
         --Debit Card is suspended
         UPDATE CARD_DEBIT
         SET status = 6 --Suspension pending
             , last_update_date = SYSDATE
         WHERE card_id = X.PERS_ID
         and   status <> 6;
         -- suspend dependent cards
         UPDATE CARD_DEBIT
         SET status = 6 --Suspension pending
             , last_update_date = SYSDATE
         WHERE card_id IN ( SELECT pers_id from PERSON where pers_main = X.PERS_ID)
         AND  STATUS IN (1,2,7);
        END IF;
    END LOOP;
exception
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
 END email_unsubstantiated_txn  ;
 PROCEDURE send_email_on_payment_diff
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Payment Amount and Claim Amount Discrepancy Report</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Payment Amount and Claim Amount Discrepancy Report</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT D.ACC_NUM, A.CLAIM_ID,A.CLAIM_DATE,a.claim_amount, SUM(NVL(C.AMOUNT,0))
        FROM   CLAIMN A, PAYMENT C, ACCOUNT D
        WHERE  C.REASON_CODE IN (11,12,19,0,60,29,6,27,28)
        AND    A.CLAIM_ID = C.CLAIMN_ID
        AND    A.PERS_ID = D.PERS_ID
        AND    A.CLAIM_STATUS IN (''PAID'',''PARTIALLY_PAID'')
        GROUP BY D.ACC_NUM, A.CLAIM_ID,a.claim_amount,A.CLAIM_DATE
        HAVING SUM(NVL(C.AMOUNT,0)) > a.claim_amount   ';

                dbms_output.put_line('sql '||l_sql);


     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'benefits@sterlingadministration.com'
                           ,'claim_payment_discreapancy_report_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Payment Amount and Claim Amount Discrepancy Report for '||to_char(sysdate,'MM/DD/YYYY'));
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_on_payment_diff;

PROCEDURE send_email_on_Amount_2500
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Claim Amount Greater Than 2500</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Claim Amount Greater than 2500</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT  A.first_name "First Name",A.last_name "Last Name",
       C.ACC_NUM "Account Number"
       ,B.CLAIM_AMOUNT  "Claim Amount",
        B.CLAIM_ID "Claim Number",
       B.Claim_status "Claim Status",
       B.Service_Type "Service Type",
       B.Creation_Date "Creation Date",
       PC_ENTRP.GET_ENTRP_NAME(B.entrp_id)"Employer"
       FROM    sam.PERSON A
      ,sam.CLAIMN B
      ,sam.ACCOUNT C
     WHERE B.PAY_REASON IN (11,12,19)
     AND  B.PERS_ID = A.PERS_ID
     AND    A.PERS_ID=  C.PERS_ID
     AND B.CLAIM_AMOUNT >=2500
     AND B.SERVICE_TYPE IS NOT NULL
     AND trunc(B.CREATION_DATE) >= trunc(SYSDATE)-1 ';

       dbms_output.put_line('sql '||l_sql);


     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,benefits@sterlingadministration.com,'||
                            'IT-Team@sterlingadministration.com,sarah.soman@sterlingadministration.com,'||
                            'Douglas.price@sterlingadministration.com,Dan.Tidball@sterlingadministration.com'
                           ,'claim_amount_greater_than_2500_report_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claim Amount Greater than 2500 for '||to_char(sysdate,'MM/DD/YYYY'));
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_on_Amount_2500;

PROCEDURE send_email_on_check_diff
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Check Amount and Claim Amount Discrepancy Report</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Check Amount and Claim Amount Discrepancy Report</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT D.ACC_NUM, A.CLAIM_ID,A.CLAIM_DATE,a.claim_amount
                  , SUM(CASE WHEN C.STATUS IN (''CANCELLED'',''PURGE_AND_REISSUE'',''PURGED'') THEN
                 -NVL(C.CHECK_AMOUNT,0) ELSE NVL(C.check_AMOUNT,0) END) CHECK_AMOUNT
        FROM   CLAIMN A, CHECKS C, ACCOUNT D
        WHERE   A.CLAIM_ID = C.entity_id
        AND    A.PERS_ID = D.PERS_ID
        AND    A.CLAIM_STATUS IN (''PAID'',''PARTIALLY_PAID'')
        GROUP BY D.ACC_NUM, A.CLAIM_ID,a.claim_amount,A.CLAIM_DATE
        HAVING SUM(CASE WHEN C.STATUS IN (''CANCELLED'',''PURGE_AND_REISSUE'',''PURGED'') THEN -NVL(C.check_AMOUNT,0)
              ELSE NVL(C.check_AMOUNT,0) END ) > a.claim_amount ';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'benefits@sterlingadministration.com,VHSTeam@sterlingadministration.com'
                           ,'check_claim_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Check Amount and Claim Amount Discrepancy Report for '||to_char(sysdate,'MM/DD/YYYY'));
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_on_check_diff;
PROCEDURE notify_claim_after_plan_yr
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Claims Created after Runout Period</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Claims Created after Runout Period</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT     b.acc_num,pc_entrp.get_entrp_name(A.ENTRP_ID) EMPLOYER_NAME,
             a.claim_id,A.CLAIM_DATE,A.CLAIM_AMOUNT,A.CLAIM_PAID,A.DENIED_REASON,
             a.claim_status,A.PLAN_START_DATE,A.PLAN_END_DATE
        FROM     CLAIMN a, account b
        WHERE    SERVICE_TYPE IS NOT NULL AND SERVICE_TYPE <> ''HSA''
        AND      A.PERS_ID = B.PERS_ID
        AND      A.CLAIM_STATUS NOT IN (''DENIED'',''CANCELLED'')
        AND      A.DENIED_REASON IS NULL
        AND      CLAIM_DATE > ( SELECT MAX(C.PLAN_END_DATE+NVL(C.GRACE_PERIOD,0)+NVL(C.RUNOUT_PERIOD_DAYS,0))
                      FROM BEN_PLAN_ENROLLMENT_SETUP C
                    WHERE  C.ACC_ID = b.acc_id and C.STATUS IN (''A'',''I'')
                     and    c.plan_type = a.service_type)     ';

          dbms_output.put_line('sql '||l_sql);


     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'benefits@sterlingadministration.com'||
                                 ',sarah.soman@sterlingadministration.com'
                           ,'claim_after_runout_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claims Created after Runout Period for '||to_char(sysdate,'MM/DD/YYYY'));
    mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'VHSTeam@sterlingadministration.com'
                           ,'claim_after_runout_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claims Created after Runout Period for '||to_char(sysdate,'MM/DD/YYYY'));

EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_claim_after_plan_yr;
PROCEDURE notify_claim_before_plan_yr
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Claims Processed before Plan Start Period</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Claims Processed before Plan Start Period</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT     b.acc_num,pc_entrp.get_entrp_name(A.ENTRP_ID) EMPLOYER_NAME,
             a.claim_id,A.SERVICE_START_DATE,A.PLAN_START_DATE,A.PLAN_END_DATE,A.CLAIM_AMOUNT,A.CLAIM_PAID,A.DENIED_REASON,
             a.claim_status,a.note
        FROM     CLAIMN a, account b
        WHERE    SERVICE_TYPE IS NOT NULL AND SERVICE_TYPE <> ''HSA''
        AND      A.PERS_ID = B.PERS_ID
        AND      A.CLAIM_STATUS NOT IN (''DENIED'',''CANCELLED'')
        AND      A.DENIED_REASON IS NULL
        AND      A.SERVICE_START_DATE <  a.plan_start_date';

          dbms_output.put_line('sql '||l_sql);


     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'benefits@sterlingadministration.com'||
                                 ',sarah.soman@sterlingadministration.com'
                           ,'claim_before_plan_start_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claims Created before plan start date  '||to_char(sysdate,'MM/DD/YYYY'));

      mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'VHSTeam@sterlingadministration.com'
                           ,'claim_before_plan_start_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claims Created before plan start date  '||to_char(sysdate,'MM/DD/YYYY'));


EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_claim_before_plan_yr;

PROCEDURE notify_service_after_plan_yr
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Service Dates in Claims Entered/Processed after Plan End Date+Grace Period</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Service Dates in Claims Entered/Processed after Plan End Date+Grace Period</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT     b.acc_num,pc_entrp.get_entrp_name(A.ENTRP_ID) EMPLOYER_NAME,
             a.claim_id,A.SERVICE_START_DATE,A.PLAN_START_DATE,A.PLAN_END_DATE,C.GRACE_PERIOD,A.CLAIM_AMOUNT,A.CLAIM_PAID,A.DENIED_REASON,
             a.claim_status,a.note
        FROM     CLAIMN a, account b ,ben_plan_enrollment_setup c,PAYMENT D
        WHERE    SERVICE_TYPE IS NOT NULL AND SERVICE_TYPE <> ''HSA''
        AND      A.PERS_ID = B.PERS_ID
        AND      A.CLAIM_STATUS NOT IN (''DENIED'',''CANCELLED'')
        AND      A.DENIED_REASON IS NULL
            AND     B.ACC_ID = C.ACC_ID
            AND     A.SERVICE_TYPE = C.PLAN_TYPE
            AND     A.PLAN_START_DATE = C.PLAN_START_DATE
            AND     A.PLAN_END_DATE = C.PLAN_END_DATE
            AND     A.CLAIM_ID = D.CLAIMN_ID
            AND     D.REASON_CODE <> 13
          and C.STATUS IN (''A'',''I'')
        AND     A.SERVICE_START_DATE >  a.plan_end_date+NVL(C.GRACE_PERIOD,0)';



     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'benefits@sterlingadministration.com,VHSTeam@sterlingadministration.com'||
                                 ',sarah.soman@sterlingadministration.com'
                           ,'claim_after_service_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Service Dates in Claims Entered/Processed after Plan End Date+Grace Period  '||to_char(sysdate,'MM/DD/YYYY'));



EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_service_after_plan_yr;
PROCEDURE notify_no_plan_yr
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>Claims with no plan year</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Claims with no plan year</p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT *
              FROM   CLAIMN
              WHERE  NVL(SERVICE_TYPE,''HSA'') <> ''HSA''
              AND    CLAIM_STATUS NOT IN (''DENIED'',''CANCELLED'')
              AND    (PLAN_START_DATE IS NULL OR PLAN_END_DATE IS NULL)';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                            ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'||
                            'benefits@sterlingadministration.com,VHSTeam@sterlingadministration.com'||
                                 ',sarah.soman@sterlingadministration.com'
                           ,'claim_no_plan_year'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Claims with no plan year  '||to_char(sysdate,'MM/DD/YYYY'));




EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_no_plan_yr;
PROCEDURE notify_takeover
IS
   l_sql VARCHAR2(3200);
BEGIN

         l_sql :=   'SELECT a.takeover_flag "Takeover Flag"
                       ,a.acc_num "Account Number "
                       ,b.name "Employer Name"
                       ,c.billing_date "Billing Date"
                       ,a.creation_date "Registration Date"
                         FROM account  a ,enterprise b , ar_invoice c
                     WHERE  a.entrp_id = b.entrp_id
                     AND  a.takeover_flag = ''Y''
                     AND  a.acc_num = c.acc_num
                     AND  c.invoice_date > trunc(sysdate,''MM'')';


         mail_utility.report_emails('benefits@sterlingadministration.com'
                           ,'finance.department@sterlingadministration.com,techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'takeover.xls'
                           , l_sql
                           , NULL
                           , 'Takeover Groups in monthly invoice');
 EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_takeover;
PROCEDURE send_email_on_bellarmine
IS
 l_sql VARCHAR2(3200);
BEGIN

         l_sql :=   'SELECT  acc_num "Account Number "
                       ,error_message
                       ,ssn
                         FROM online_enrollment
                     WHERE  a.entrp_id  = 11958';


         mail_utility.report_emails('bellarmine@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'bellarmine'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , NULL
                           , 'Bellarmine Enrollments');
 EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END send_email_on_bellarmine;
  PROCEDURE email_rate_plan_details
  IS
    l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title>Rate Plan Details Report</title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p>Rate Plans detail Report</p>
             </table>
              </body>
        </html>';



    L_Sql := 'SELECT b.rate_plan_name "Plan Name"
                    , A.EFFECTIVE_DATE "Effective Date"
                    , A.EFFECTIVE_END_DATE "End Date"
                    ,PC_LOOKUPS.GET_REASON_NAME(A.RATE_CODE) "Reason Name"
                    ,A.RATE_PLAN_COST "Adjustment Amount"
              FROM RATE_PLAN_DETAIL A, RATE_PLANS B
              WHERE upper(DESCRIPTION) = upper(''Applying excess credit to next month'')
              AND A.RATE_PLAN_ID = B.RATE_PLAN_ID';

               dbms_output.put_line('sql '||l_sql);
 Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'Rate Plan details Report'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Rate Plan Details Report for '||to_char(sysdate,'MM/DD/YYYY'));
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
End   Email_Rate_Plan_Details;

 PROCEDURE email_invoice_report_details
  IS
    l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title>Invoice Report with ACH amount more than invoice amount</title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p>Invoice Report with ACH amount more than invoice amount</p>
             </table>
              </body>
        </html>';

      L_Sql := 'SELECT B.INVOICE_ID "Invoice ID"
              , B.INVOICE_AMOUNT "Invoice Amount"
              , B.VOID_AMOUNT "Void Amount"
              , A.TOTAL_AMOUNT "Total Amount"
              , a.transaction_date "Transaction Date"
              FROM  ACH_TRANSFER A, AR_INVOICE B
              WHERE A.INVOICE_ID = B.INVOICE_ID
              AND   A.STATUS IN (1,2)
              AND   A.TRANSACTION_TYPE = ''F''
              and   A.TOTAL_AMOUNT > 0
              and   a.total_amount > B.INVOICE_AMOUNT- B.VOID_AMOUNT';

               dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'Invoice Report'||To_Char(Sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , L_Html_Message
                           , 'Invoice Report'||to_char(sysdate,'MM/DD/YYYY'));
      IF TO_CHAR(SYSDATE,'DD') BETWEEN '15' AND '23' THEN
      L_SQL := 'SELECT B.INVOICE_ID "Invoice ID"
              , B.INVOICE_AMOUNT "Invoice Amount"
              , B.VOID_AMOUNT "Void Amount"
              , A.TOTAL_AMOUNT "Total Amount"
              , SUM(C.CHECK_AMOUNT) "Posted Amount"
              , A.TRANSACTION_DATE "Transaction Date"
              FROM  ACH_TRANSFER A, AR_INVOICE B,EMPLOYER_PAYMENTS C
              WHERE A.INVOICE_ID = B.INVOICE_ID
              AND   A.STATUS = 3
              AND   B.STATUS <> ''VOID''
              AND   A.INVOICE_ID= C.INVOICE_ID
              AND   A.TRANSACTION_TYPE = ''F''
              and   A.TOTAL_AMOUNT > 0
              and   a.total_amount > B.INVOICE_AMOUNT- B.VOID_AMOUNT
              group by B.INVOICE_ID
              , B.INVOICE_AMOUNT
              , B.VOID_AMOUNT
              , A.TOTAL_AMOUNT
              HAVING SUM(C.CHECK_AMOUNT) <> A.TOTAL_AMOUNT';

         Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'ACH_more_than_invoice'||To_Char(Sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , L_Html_Message
                           , 'Invoice Report'||to_char(sysdate,'MM/DD/YYYY'));
     END IF;
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    Dbms_Output.Put_Line('error message '||Sqlerrm);
   END   email_invoice_report_details;
   PROCEDURE email_void_invoice_report
  IS
    l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title>VOID Invoice Report</title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p>Void Invoice Report</p>
             </table>
              </body>
        </html>';

      L_Sql := 'SELECT  A.ACC_NUM
      , A.INVOICE_ID
      , A.INVOICE_DATE
      , A.START_DATE
      , A.END_DATE
      , A.APPROVED_DATE
      , A.VOID_DATE
      , A.INVOICE_AMOUNT
      , A.PAID_AMOUNT
      , A.INVOICE_TERM
      , A.PAYMENT_METHOD
      , A.BILLING_NAME
      , A.BILLING_ATTN
      , A.BILLING_ADDRESS||'',''||A.BILLING_CITY||'',''||A.BILLING_STATE||'' ,''||A.BILLING_ZIP  BILLING_ADDRESS
      , a.plan_type ACCOUNT_TYPE
     -- , C.REASON_NAME
      , B.TOTAL_LINE_AMOUNT
      , B.VOID_AMOUNT "Voided Line Amount"
      --, PC_PERSON.ACC_NUM(CN.PERS_ID) EE_ACC_NUM
      --, DECODE(a.STATUS,''GENERATED'',''In Process'',''PROCESSED'',''Approved'',''POSTED'',''Got Payment'',''VOID'',''Void'') STATUS
    --  , ID.ENTITY_ID CLAIM_ID
     -- , ID.RATE_AMOUNT CLAIM_AMOUNT
      --, CN.SERVICE_TYPE
FROM   AR_INVOICE A, AR_INVOICE_LINES B, ACCOUNT D
WHERE  A.INVOICE_ID = B.INVOICE_ID
AND    A.ACC_ID = D.ACC_ID
--AND    B.STATUS <> ''VOID''
--AND    ID.ENTITY_ID = CN.CLAIM_ID
--AND    ID.ENTITY_TYPE = ''CLAIMN''
--AND    B.INVOICE_LINE_ID = ID.INVOICE_LINE_ID
--AND    B.RATE_CODE = TO_CHAR(C.REASON_CODE)
AND    A.STATUS = ''VOID''
AND A.INVOICE_REASON=''FEE''
AND D.ACCOUNT_TYPE=''COBRA''
AND TRUNC(A.VOID_DATE) >= ADD_MONTHS((LAST_DAY(SYSDATE)+1),-1)
AND TRUNC(A.VOID_DATE) <= add_months(trunc(sysdate) - (to_number(to_char(sysdate,''DD'')) - 1), 1) -1';

  dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'Void Invoice Report'||To_Char(Sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , L_Html_Message
                            ,'Void Invoice Report '||to_char(sysdate,'MM/DD/YYYY'));

EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.

    Dbms_Output.Put_Line('error message '||Sqlerrm);
   END   email_void_invoice_report;

   PROCEDURE email_suspended_cards
   is

     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title>Benefits: Suspended Cards of HRA/FSA accounts due to Debit card Substantiation </title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p>Benefits: Suspended Cards of HRA/FSA accounts due to Debit card Substantiation </p>
             </table>
              </body>
        </html>';
      L_Sql := 'SELECT  FIRST_NAME "First Name",MIDDLE_NAME "Middle Name",LAST_NAME "Last Name"
                       ,ACC_NUM "Account Number",EMPLOYER_NAME "Employer Name",NO_OF_UNSUB "No of Unsubstantiated Claims"
                FROM TABLE(PC_REPORTS_PKG.get_suspended_cards_rep(NULL,NULL)) WHERE 1=1';

      dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'benefits@sterlingadministration.com,techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'suspended_cards_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Benefits: Suspended Cards of HRA/FSA accounts due to Debit card Substantiation ');
   END email_suspended_cards;
      PROCEDURE email_multi_product_client
   is

     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title> Employers that have MultiProduct with COBRA </title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p> Employers that have MultiProduct with COBRA </p>
             </table>
              </body>
        </html>';
       L_Sql := 'SELECT  NAME "Employer Name",entrp_code "EIN",acc_num "Account Number"
                       ,to_char(START_DATE,''mm/dd/yyyy'') "Effective Date"
                       ,to_char(CREATION_DATE,''mm/dd/yyyy'') "Creation Date"
                FROM cobra_multi_product_er_v WHERE 1=1';

      dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'cobra@sterlingadministration.com,techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                           ,'multi_product_er_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Employers that have MultiProduct with COBRA ');
   END email_multi_product_client;

   PROCEDURE Email_HSA_Enrollment_Numbers
  IS
     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);

BEGIN

    l_html_message  := '<html>
      <head>
          <title>HSA Enrollment Numbers</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> HSA Enrollment Numbers </p>
       </table>
        </body>
        </html>';

    l_sql := 'Select
      SUM(CASE WHEN ACCOUNT_STATUS !=5 AND  TRUNC(Reg_date) Between trunc(trunc(sysdate,''MM'')-1,''MM'') and trunc(sysdate,''MM'')-1   THEN 1 ELSE 0 END)"ENROLLMENTS"
    ,SUM(CASE WHEN ACCOUNT_STATUS !=5  AND TRUNC(end_date) Between trunc(trunc(sysdate,''MM'')-1,''MM'')and trunc(sysdate,''MM'')-1  THEN 1 ELSE 0 END)"TERMINATIONS"
   ,SUM (CASE WHEN (BLOCKED_FLAG=''N'' OR BLOCKED_FLAG IS NULL)and ACCOUNT_STATUS  IN (1,2) THEN 1 ELSE 0 END)"Total Active/Suspended"
   from    account A where  A.ENTRP_ID IS  NULL AND A.ACCOUNT_TYPE =''HSA'' ';

        dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com'
                           ,'HSA_Enrollment_Numbers'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HSA Enrollment Numbers(Executive)'||to_char(sysdate,'MM/DD/YYYY'));

                             UTL_FILE.FCOPY (
    'MAILER_DIR' , --THIS IS A ORACLE DIRECTORY
    'HSA_Enrollment_Numbers'||to_char(sysdate,'mmddyyyy')||'.xls' , --FILE NAME
    'REPORT_DIR' , --THIS IS A ORACLE DIRECTORY
    'HSA_Enrollment_Numbers'||to_char(sysdate,'mmddyyyy')||'.xls' ); --DESTINATION FILE

   exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.
   Dbms_Output.Put_Line('error message '||Sqlerrm);

   END Email_HSA_Enrollment_Numbers;

  PROCEDURE Email_FSA_New_Enrollments
IS
     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);

BEGIN
   -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>FSA Enrollment Numbers</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> FSA Enrollment Numbers </p>
       </table>
        </body>
        </html>';

    l_sql := '
  select
     count(ACC_ID) AS "New FSA in Prior Month"
   from account
   where account_type=''FSA''
   and TRUNC(REG_date) between  trunc(trunc(sysdate,''MM'')-1,''MM'') and trunc(sysdate,''MM'')-1
    AND ENTRP_ID IS NULL
    AND ACCOUNT_STATUS NOT IN (4,5)';

        dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,g_cc_email ||',shavee.kapoor@sterlingadministration.com'
                           ,'FSA_Enrollment_Numbers_Prior_Month'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'FSA New Enrollments for the Month(Executive)'||to_char(sysdate,'MM/DD/YYYY'));

      UTL_FILE.FCOPY (
    'MAILER_DIR' , --THIS IS A ORACLE DIRECTORY
    'FSA_Enrollment_Numbers_Prior_Month'||to_char(sysdate,'mmddyyyy')||'.xls' , --FILE NAME
    'REPORT_DIR' , --THIS IS A ORACLE DIRECTORY
    'FSA_Enrollment_Numbers_Prior_Month'||to_char(sysdate,'mmddyyyy')||'.xls' ); --DESTINATION FILE

   exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.
   Dbms_Output.Put_Line('error message '||Sqlerrm);

   END Email_FSA_New_Enrollments;

   PROCEDURE Email_FSA_Enrollment_Numbers
AS
     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);

BEGIN
   -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>FSA Enrollment Numbers</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> FSA Enrollment Numbers </p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT
    COUNT(DISTINCT(A.ACC_ID)) AS "Total Active FSA Accounts"
    FROM BEN_PLAN_ENROLLMENT_SETUP B ,
           ACCOUNT A,
           ACCOUNT ER,
           PERSON p
    WHERE A.ACC_ID        = B.ACC_ID
    AND   B.ENTRP_ID IS NULL
    AND   A.ENTRP_ID IS NULL
    AND B.ACC_ID          = A.ACC_ID
    AND A.ACCOUNT_TYPE    = ''FSA''
    AND B.PLAN_END_DATE > SYSDATE
    AND B.STATUS=''A''
    AND A.PERS_ID=P.PERS_ID
    AND TRUNC(A.rEG_DATE) < = trunc(sysdate,''MM'')-1
    AND P.ENTRP_ID=ER.ENTRP_ID
    AND ER.ACCount_status!=4
    AND A.ACCOUNT_STATUS NOT IN (4,5)';

       --  dbms_output.put_line('sql'||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com'
                           ,'FSA_Active_Numbers_Total'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'FSA Enrollment Numbers(Executive)'||to_char(sysdate,'MM/DD/YYYY'));

                             UTL_FILE.FCOPY (
    'MAILER_DIR' , --THIS IS A ORACLE DIRECTORY
    'FSA_Active_Numbers_Total'||to_char(sysdate,'mmddyyyy')||'.xls' , --FILE NAME
    'REPORT_DIR' , --THIS IS A ORACLE DIRECTORY
    'FSA_Active_Numbers_Total'||to_char(sysdate,'mmddyyyy')||'.xls' ); --DESTINATION FILE

   exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.
   Dbms_Output.Put_Line('error message '||Sqlerrm);

   END Email_FSA_Enrollment_Numbers;

     PROCEDURE Email_HRA_New_Enrollments
IS
     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);

BEGIN
   -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA Enrollment Numbers</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> HRA Enrollment Numbers </p>
       </table>
        </body>
        </html>';

    l_sql := '
  select
     count(ACC_ID) AS "New HRA in Prior Month"
   from account
   where account_type=''HRA''
   and TRUNC(REG_date) between  trunc(trunc(sysdate,''MM'')-1,''MM'') and trunc(sysdate,''MM'')-1
    AND ENTRP_ID IS NULL
    AND ACCOUNT_STATUS NOT IN (4,5)';

        dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,g_cc_email ||',shavee.kapoor@sterlingadministration.com'
                           ,'HRA_Enrollment_Numbers_Prior_Month'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA New Enrollments for the Month(Executive)'||to_char(sysdate,'MM/DD/YYYY'));

      UTL_FILE.FCOPY (
    'MAILER_DIR' , --THIS IS A ORACLE DIRECTORY
    'HRA_Enrollment_Numbers_Prior_Month'||to_char(sysdate,'mmddyyyy')||'.xls' , --FILE NAME
    'REPORT_DIR' , --THIS IS A ORACLE DIRECTORY
    'HRA_Enrollment_Numbers_Prior_Month'||to_char(sysdate,'mmddyyyy')||'.xls' ); --DESTINATION FILE

   exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.
   Dbms_Output.Put_Line('error message '||Sqlerrm);

   END Email_HRA_New_Enrollments;

   PROCEDURE Email_HRA_Enrollment_Numbers
AS
     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);

BEGIN
   -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA Enrollment Numbers</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> HRA Enrollment Numbers </p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT
    COUNT(DISTINCT(A.ACC_ID)) AS "Total Active HRA Accounts"
    FROM BEN_PLAN_ENROLLMENT_SETUP B ,
           ACCOUNT A,
           ACCOUNT ER,
           PERSON p
    WHERE A.ACC_ID        = B.ACC_ID
    AND   B.ENTRP_ID IS NULL
    AND   A.ENTRP_ID IS NULL
    AND B.ACC_ID          = A.ACC_ID
    AND A.ACCOUNT_TYPE    = ''HRA''
    AND B.PLAN_END_DATE > SYSDATE
    AND B.STATUS=''A''
    AND A.PERS_ID=P.PERS_ID
    AND TRUNC(A.rEG_DATE) < = trunc(sysdate,''MM'')-1
    AND P.ENTRP_ID=ER.ENTRP_ID
    AND ER.ACCount_status!=4
    AND A.ACCOUNT_STATUS NOT IN (4,5)';

       --  dbms_output.put_line('sql'||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com'
                           ,'HRA_Active_Numbers_Total'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA Enrollment Numbers(Executive)'||to_char(sysdate,'MM/DD/YYYY'));

                             UTL_FILE.FCOPY (
    'MAILER_DIR' , --THIS IS A ORACLE DIRECTORY
    'HRA_Active_Numbers_Total'||to_char(sysdate,'mmddyyyy')||'.xls' , --FILE NAME
    'REPORT_DIR' , --THIS IS A ORACLE DIRECTORY
    'HRA_Active_Numbers_Total'||to_char(sysdate,'mmddyyyy')||'.xls' ); --DESTINATION FILE

   exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.
   Dbms_Output.Put_Line('error message '||Sqlerrm);

   END Email_HRA_Enrollment_Numbers;

   PROCEDURE Email_Pop_Renewals_Details
  IS
     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
     v_email          varchar2(100);
     l_emailid        varchar2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title>Pop Renewals Report</title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p>Pop Renewals Report</p>
             </table>
              </body>
        </html>';

	/* commented by Joshi for 12525. 
    L_Sql := 'SELECT PC_ENTRP.GET_ENTRP_NAME(ENTRP_ID) "Employer Name"
                 ,   ROUND(MONTHS_BETWEEN(SYSDATE,START_DATE)) "Renewal Months"
              ,ACC_NUM
              ,start_date
                 from account where account_type = ''POP''
                   AND ROUND(MONTHS_BETWEEN(SYSDATE,START_DATE)) BETWEEN 58 AND 60';
				   */
	l_sql := 'SELECT X.ACC_NUM
                    ,B.NAME
                    ,X.PLAN_YEAR
				FROM ACCOUNT A
				    ,TABLE(PC_WEB_COMPLIANCE.GET_ER_PLANS(A.ACC_ID, ''POP'',NULL)) X
				    ,ENTERPRISE B
		   	   WHERE A.ACCOUNT_TYPE = ''POP''
			  	 AND A.ENTRP_ID=B.ENTRP_ID
				 AND B.STATE !=''HI''
				 AND A.ACCOUNT_STATUS= 1
				 AND A.END_DATE IS NULL
				 AND X.ACC_ID = A.ACC_ID' ;	   

	IF USER <> 'SAM' THEN
		l_emailid := 'IT-Team@sterlingadministration.com';
	ELSE
		l_emailid := 'compliance@sterlingadministration.com,accountmanager@sterlingadministration.com,suzie.roehrenbach@sterlingadministration.com,cindy.antonelli@sterlingadministration.com';
	END IF;

	/* commented by Joshi for 12525. 
    for i in(SELECT distinct salesrep_id
                 from account where account_type = 'POP'
                   AND ROUND(MONTHS_BETWEEN(SYSDATE,START_DATE)) BETWEEN 58 AND 60)
    loop


	if i.salesrep_id is not null then
        begin
          select email into v_email
          from employee e, salesrep s
          where e.emp_id = s.emp_id
          and s.salesrep_id = i.salesrep_id;
        exception
          when no_data_found then
               v_email := null;
        end;
           if v_email is not null then
               l_emailid := l_emailid||','||v_email;
           end if;
      end if;
    end loop;
	*/


    --dbms_output.put_line('emailids '||l_emailid);
 Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,l_emailid
                           ,'Pop_Renewals_Report_'||to_char(sysdate,'mmddyyyy')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Pop Renewals Report for '||to_char(sysdate,'MM/DD/YYYY'));
EXCEPTION
  WHEN OTHERS THEN
-- Close the file if something goes wrong.
    pc_log.log_error('pc_notifications.Email_Pop_Renewals_Details Error ' , SQLERRM);
--    dbms_output.put_line('error message '||SQLERRM);
End Email_Pop_Renewals_Details;

PROCEDURE hrafsa_approval_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>HRA/FSA Appproval Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Appproval Report  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT  a.first_name||'' ''||a.middle_name||'' ''||a.last_name "Employee Name"
                          , pc_entrp.get_entrp_name(a.entrp_id) "Employer Name"
                          , b.acc_num "Account Number"
                          /*, to_char(b.start_date,''MM/DD/YYYY'') "Account Effective Date"*/
                          , to_char(c.EFFECTIVE_DATE ,''MM/DD/YYYY'') "Plan Effective Date"
                          , c.plan_type "Plan Type"
                          /*, to_char(c.plan_start_date,''MM/DD/YYYY'') "Plan Start Date"*/
                         /* , to_char(c.plan_end_date,''MM/DD/YYYY'') "Plan End Date"*/
                                , D.annual_election "Annual Election"
                          , D.FIRST_PAY_DATE  "First Payroll Date"
                          , D.PAY_CONTRIB "Pay Contribution"
                          , d.EFFECTIVE_DATE  "Payroll Effective Date"
                          , e.NO_OF_PERIODS "No of Periods"
                          , e.PAY_CYCLE "Pay Cycle"
                          , Decode(d.status ,''A'',''Approved'',''R'',''Rejected'') "Approved/Rejected"
                          , d.reject_reason "Reject Reason"
                          , to_char(d.approved_date,''MM/DD/YYYY'') "Approved Date"
                          , to_char(d.rejected_date,''MM/DD/YYYY'') "Rejected Date"
                    FROM    ACCOUNT B, PERSON a
                           , BEN_PLAN_ENROLLMENT_SETUP C
                           , BEN_PLAN_APPROVALS D
                          , PAY_DETAILS e
                    WHERE   B.ACCOUNT_TYPE IN (''HRA'',''FSA'')
                     AND    A.PERS_ID = B.PERS_ID
                     AND    C.ACC_ID = B.ACC_ID
                     AND    C.BEN_PLAN_ID = D.BEN_PLAN_ID
                     AND    C.ACC_ID = E.ACC_ID
                     and C.STATUS IN (''A'',''I'')
                     AND    D.BEN_PLAN_ID = E.BEN_PLAN_ID
                     AND    (TRUNC(D.APPROVED_DATE) = TRUNC(SYSDATE)-1
                            OR  TRUNC(D.REJECTED_DATE) = TRUNC(SYSDATE)-1)';


    dbms_output.put_line('sql '||l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                             ,g_hrafsa_email||','||'VHSTeam@sterlingadministration.com'
                            ,'hra_fsa_approvals'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Approval Report for '||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END hrafsa_approval_report;
PROCEDURE compliance_payment_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>Compliance Products Payment Posted Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Compliance Products Payment Posted Report  </p>
       </table>
        </body>
        </html>';
  /*  l_sql := 'SELECT C.NAME "Employer Name", C.ADDRESS "Address", C.CITY "City"
                    , C.STATE "State",C.ZIP "Zip",b.acc_num "Account Number"
            , A.check_amount "Check Amount", to_char(a.check_date,''MM/DD/YYYY'') "Check Date"
            , B.ACCOUNT_TYPE "Product"
        FROM  EMPLOYER_PAYMENTS A, ACCOUNT B, ENTERPRISE C
        WHERE A.ENTRP_ID  = B.ENTRP_ID
        AND   A.ENTRP_ID = C.ENTRP_ID
        AND   B.ACCOUNT_TYPE  in (''POP'',''ERISA_WRAP'',''FORM_5500'',''COMPLIANCE'')
        and   trunc(A.CREATION_DATE) >= trunc(SYSDATE)-1 ';


    dbms_output.put_line('sql '||l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                             ,'lola.christensen@sterlingadministration.com'
                           ,'pop_payments.xls'
                           , l_sql
                           , l_html_message
                           , 'POP Payment Posted Report '||to_char(sysdate-1,'MM/DD/YYYY'));
      */
       l_html_message  := '<html>
      <head>
          <title>Compliance Products Payment Posted Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Compliance Products Payment Posted Report  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT C.NAME "Employer Name", C.ADDRESS "Address", C.CITY "City"
                    , C.STATE "State",C.ZIP "Zip",b.acc_num "Account Number"
            , A.check_amount "Check Amount", to_char(a.check_date,''MM/DD/YYYY'') "Check Date"
            , B.ACCOUNT_TYPE "Product"
            ,A.invoice_id "Invoice"
            ,L.START_DATE "Start Date"
            ,L.END_DATE "End Date"
         FROM  EMPLOYER_PAYMENTS A, ACCOUNT B, ENTERPRISE C, AR_INVOICE L
        WHERE A.ENTRP_ID  = B.ENTRP_ID
        AND   A.ENTRP_ID = C.ENTRP_ID
        AND A.INVOICE_ID=L.INVOICE_ID
        AND   B.ACCOUNT_TYPE  in (''POP'',''ERISA_WRAP'',''FORM_5500'',''COMPLIANCE'')
        and   trunc(A.CREATION_DATE) >= trunc(SYSDATE)-1';


    dbms_output.put_line('sql '||l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                             ,'compliance@sterlingadministration.com'
                           ,'compliance_payments'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Compliance Products Payment Posted Report '||to_char(sysdate-1,'MM/DD/YYYY'));
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END compliance_payment_report;
PROCEDURE hrafsa_ae_change_report
 AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
  -- IF to_char(sysdate,'DD') = '01' THEN

   l_html_message  := '<html>
      <head>
          <title>HRA/FSA Annual Election Changes Report </title>
      </head>
     <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>HRA/FSA Annual Election Changes Report  </p>
       </table>
        </body>
        </html>';
    l_sql := 'select bleh.ACC_NUM "Account Number"
                 , p.first_name||'' ''||p.last_name "Name"
                 , pc_entrp.get_entrp_name(bleh.entrp_id) "Employer Name"
                 , bleh.effective_date "Effective Date"
                 , bps.plan_type "Plan Type"
                 , lk.description "Life Event"
                 , bleh.description "Notes"
                 , bps.annual_election "Current Annual election"
                 , nvl(bleh.annual_election,0) "New Annual election"
                 , bleh.payroll_contribution "Payroll Contribution"
            from ben_life_event_history bleh,lookups lk,ben_plan_enrollment_setup bps, person p
            where  bleh.life_event_code= lk.lookup_code
            AND    NVL(bleh.PROCESSED_STATUS,''N'')= ''Y''
                and    bleh.status = ''A'' AND bleh.pers_id = p.pers_id
            and BPS.STATUS IN (''A'',''I'')
                and    bps.ben_plan_id(+)    = bleh.ben_plan_id
            AND    trunc(bleh.EFFECTIVE_DATE)  >= trunc(SYSDATE-1)
                and    lk.lookup_name        = ''LIFE_EVENT_CODE''  ';


   dbms_output.put_line('sql '||l_sql);

     Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                             , g_hrafsa_email||','||'VHSTeam@sterlingadministration.com,vanitha.subramanyam@sterlinghsa.com'
                           ,'hra_fsa_ae_changes'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'HRA/FSA Annual Election Changes Report for '||to_char(sysdate,'MM/DD/YYYY'));
--  END IF;

exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

   Dbms_Output.Put_Line('error message '||Sqlerrm);
END hrafsa_ae_change_report;
/** debit card adjustcation debit card document claim **/
PROCEDURE insert_deny_debit_claim_event
  (P_CLAIM_ID          IN NUMBER
  ,p_event_name        IN VARCHAR2
  ,P_USER_ID           IN NUMBER)
  IS
    L_EVENT_TYPE VARCHAR2(30);
    l_return_status VARCHAR2(255) := 'S';
    l_error_message VARCHAR2(255);
    l_error         EXCEPTION;
    l_process_flag  VARCHAR2(255) := 'N';
 BEGIN
   --  claim is denied

   FOR X IN ( SELECT nvl(pc_users.get_email(a.acc_num, a.acc_id, b.pers_id),e.email) email
                    ,b.claim_id
                    ,a.acc_id
                    ,a.acc_num
                    ,b.pers_id
               FROM   ACCOUNT a
                  ,  claimn b
                  ,  person e
              WHERE   b.claim_id = p_claim_id
          AND     a.pers_id = b.pers_id
          AND     b.pers_id = e.pers_id  )
   LOOP

         IF x.email IS NULL THEN
              L_EVENT_TYPE := 'PAPER';
          ELSE
              L_EVENT_TYPE := 'EMAIL';
         END IF;
          INSERT_EVENT_NOTIFICATIONS
         (P_EVENT_NAME   => p_event_name
         ,P_EVENT_TYPE   => L_EVENT_TYPE
         ,P_EVENT_DESC   => 'Debit Claim Document Denial for '||x.acc_num
         ,P_ENTITY_TYPE  => 'CLAIMN'
         ,P_ENTITY_ID    => x.claim_id
         ,P_ACC_ID       => x.acc_id
         ,P_ACC_NUM      => x.acc_num
         ,P_PERS_ID      => x.pers_id
         ,P_USER_ID      => P_USER_ID
         ,P_EMAIL        => x.email
         ,P_TEMPLATE_NAME => CASE WHEN p_event_name = 'DEBIT_CLAIM_DENIAL' THEN 'DEBIT_CARD_ADJ_CLAIM_DENIAL'
                                  WHEN p_event_name = 'DEBIT_CARD_ADJ_FUTURE_CLAIM_OFFSET' THEN 'DEBIT_CARD_ADJ_FUTURE_CLAIM_OFFSET'
                             END
         ,X_RETURN_STATUS => l_return_status
         ,X_ERROR_MESSAGE => l_error_message);

         IF l_return_status <> 'S' THEN
                  ROLLBACK;
                  RAISE  l_error;
         END IF;
   END LOOP;


exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END insert_deny_debit_claim_event;
   FUNCTION get_claim_deny_letter RETURN claim_deny_t PIPELINED DETERMINISTIC
  IS
     l_record claim_deny_row_t;
     CURSOR claim_cur
     IS
          SELECT   e.entity_id
                  ,  e.acc_num
                  ,  e.event_id
                  ,  nvl(pc_entrp.get_entrp_name(c.entrp_id),'') employer_name
                  ,  nvl(c.claim_amount,'') claim_amount
                  ,  nvl(c.deductible_amount,'')  deductible_amount
                  ,  nvl(c.denied_amount,'') denied_amount
                  ,  nvl(c.claim_pending,'') claim_pending
                  ,  nvl(c.claim_paid,'') claim_paid
                  ,  nvl(c.claim_id,'') claim_id
                  ,  nvl(b.first_name,'') ||' '||nvl(b.middle_name,'') ||' '||nvl(b.last_name,'')  person_name
                  ,  CASE WHEN c.denied_amount = 0 and c.deductible_amount > 0 THEN
                             'Claim Applied towards deductible'
                     ELSE  nvl(pc_lookups.GET_DENIED_REASON(c.denied_reason),'')
                                         END denied_reason
                  ,  nvl(c.claim_status,'') claim_status
                  ,  e.event_name
                  ,  nvl(B.address,'') address
                  ,  B.city||' '||B.state||' '||B.zip address2
                  ,  to_char(c.reviewed_date,'MM/DD/YYYY') reviewed_date
                  ,  TO_CHAR(C.SERVICE_START_DATE,'MM/DD/YYYY') SERVICE_START_DATE
                  ,  C.PROV_NAME prov_name
                  ,  c.source_claim_id
            FROM   EVENT_NOTIFICATIONS E
                 , CLAIMN C
                 , PERSON B
            WHERE   E.EVENT_NAME IN ('DEBIT_CARD_ADJ_FUTURE_CLAIM_OFFSET', 'DEBIT_CLAIM_DENIAL','CLAIM_DENIAL','CLAIM_PARTIAL_DENIAL')
             AND   E.ENTITY_ID = C.CLAIM_ID
             AND   C.PERS_ID = B.PERS_ID
             AND    NVL(E.PROCESSED_FLAG,'N') = 'N'
             AND    E.EVENT_TYPE = 'PAPER'
             AND    ((C.DENIED_AMOUNT > 0 AND E.EVENT_NAME  IN ('CLAIM_DENIAL', 'CLAIM_PARTIAL_DENIAL'))
                       OR E.EVENT_NAME IN ('DEBIT_CARD_ADJ_FUTURE_CLAIM_OFFSET', 'DEBIT_CLAIM_DENIAL'))
             AND    E.ENTITY_TYPE= 'CLAIMN';

             TYPE claim_row IS TABLE OF claim_cur%ROWTYPE;
             l_claim_row claim_row;
    BEGIN

          OPEN claim_cur;

           LOOP
                FETCH claim_cur BULK COLLECT INTO l_claim_row;

                FOR i IN 1 .. l_claim_row.COUNT LOOP

                     l_record.ENTITY_ID                        := l_claim_row(i).ENTITY_ID  ;
                     l_record.ACC_NUM                          := l_claim_row(i).ACC_NUM  ;
                     l_record.EVENT_ID                         := l_claim_row(i).EVENT_ID  ;
                     l_record.EMPLOYER_NAME                    := l_claim_row(i).EMPLOYER_NAME  ;
                     l_record.claim_amount                     := l_claim_row(i).claim_amount ;
                     l_record.deductible_amount                := l_claim_row(i).deductible_amount ;
                     l_record.denied_amount                    := l_claim_row(i).denied_amount  ;
                     l_record.claim_pending                    := l_claim_row(i).claim_pending ;
                     l_record.claim_paid                       := l_claim_row(i).claim_paid   ;
                     l_record.claim_id                         := l_claim_row(i).claim_id   ;
                     l_record.person_name                      := l_claim_row(i).person_name;
                     l_record.denied_reason                    := l_claim_row(i).denied_reason;
                     l_record.claim_status                     := l_claim_row(i).claim_status;
                     l_record.event_name                       := l_claim_row(i).event_name  ;
                     l_record.address                          := l_claim_row(i).address   ;
                     l_record.address2                         := l_claim_row(i).address2   ;
                     l_record.reviewed_date                    := l_claim_row(i).reviewed_date;
                     l_record.SERVICE_START_DATE               := l_claim_row(i).SERVICE_START_DATE;
                     l_record.prov_name                        := l_claim_row(i).prov_name;
                     l_record.source_claim_id                  := l_claim_row(i).source_claim_id;
                     l_record.source_prov_name                 := NULL;
                     l_record.source_service_date              := NULL;
                     l_record.source_claim_amount              := NULL;
                     IF l_claim_row(i).source_claim_id IS NOT NULL THEN
                             FOR x IN ( SELECT to_char(service_start_date,'MM/DD/YYYY') service_start_date
                                             , prov_name,claim_amount FROM CLAIMN
                                        WHERE  claim_id = l_claim_row(i).source_claim_id)
                             LOOP
                                     l_record.source_prov_name                 := X.prov_name ;
                                     l_record.source_service_date              := X.service_start_date ;
                                     l_record.source_claim_amount              := X.claim_amount;
                             END LOOP;
                     END IF;
                     PIPE ROW (l_record);
               END LOOP;

                EXIT WHEN claim_cur%NOTFOUND;
           END LOOP;
    END get_claim_deny_letter;
    PROCEDURE Email_FSA_EE_with_COBRA
    IS
      l_sql VARCHAR2(3200);
    BEGIN
         l_sql := 'SELECT  *
                   FROM    cobra_multi_product_ee_v v
                   WHERE account_type in (''HRA'',''FSA'')
                   AND   account_status <> 4
                   AND exists ( select * from ben_plan_enrollment_setup b where v.other_acc_id = b.acc_id
                                  and b.plan_end_date > SYSDATE
                                 and b.effective_end_date is NULL and b.status = ''A'')' ;

         mail_utility.report_emails('oracle@sterlingadministration.com'
                               ,'benefits@sterlingadministration.com,techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
                               ,'ees_in_cobra.xls'
                               , l_sql
                               , NULL
                               , 'FSA/HRA Employee in COBRA ');
     EXCEPTION
      WHEN OTHERS THEN
    -- Close the file if something goes wrong.

        dbms_output.put_line('error message '||SQLERRM);
    END Email_FSA_EE_with_COBRA;
    PROCEDURE notify_eob_claims
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN


       l_html_message  := '<html>
      <head>
          <title>Unsubstantiated Claim with EOB </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Unsubstantiated Claim with EOB  </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT D.ACC_NUM "Account Number", NVL(A.PROVIDER_NAME,A.DESCRIPTION) "Provider Name"
                   , A.SERVICE_DATE_FROM "Service Date", A.SERVICE_AMOUNT "Service Amount", A.AMOUNT_DUE "Amount Due"
            ,  (SELECT count(*) FROM CLAIMN E WHERE D.PERS_ID = E.PERS_ID
                   AND E.UNSUBSTANTIATED_FLAG = ''Y'') "No of Claims Waiting to Substantiate"
            ,  (SELECT count(*) FROM CLAIMN E WHERE D.PERS_ID = E.PERS_ID
                   AND E.CLAIM_STATUS = ''PENDING_DOC'') "No of Claims Waiting for Document"
        from eob_header a
           , online_users b
           , person c
           , account d
         where a.user_id = b.user_id
        and   b.tax_id= REPLACE(c.ssn,''-'')
        AND   C.PERS_ID = D.PERS_ID
        AND   D.ACCOUNT_TYPE IN (''HRA'',''FSA'')
        AND   EXISTS ( SELECT * FROM CLAIMN E WHERE D.PERS_ID = E.PERS_ID
                   AND (E.UNSUBSTANTIATED_FLAG = ''Y'' OR E.CLAIM_STATUS = ''PENDING_REVIEW''))';


    dbms_output.put_line('sql '||l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                             ,'benefits@sterlingadministration.com'
                           ,'eob_pending'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Report of Unsubstantiated Claim with EOB ');
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_eob_claims;
PROCEDURE notify_comp_discrim_testing
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN


       l_html_message  := '<html>
      <head>
          <title> </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Non Discrimination Compliance Testing Tracking Report </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT PC_ENTRP.GET_ENTRP_NAME(C.ENTRP_ID) "Employer Name"
            ,  C.ACC_NUM "Account #",B.PLAN_TYPE "Product"
            ,  TO_CHAR(B.PLAN_START_DATE,''MM/DD/YYYY'') "Benefit Plan Create Date"
            ,  TO_CHAR(B.PLAN_END_DATE,''MM/DD/YYYY'') "Benefit Plan End Date"
            ,  DECODE(A.NOTICE_TYPE,''1ST_QTR_NDT'',''Preliminary Discrimination Testing'',
                       ''LAST_QTR_NDT'',''Final Discrimination Testing'') "Notice Type"
             ,  TO_CHAR(A.NOTICE_REVIEW_SENT,''MM/DD/YYYY'') "Date Sent For Review"
            ,  TO_CHAR(A.NOTICE_RECEIVED_ON,''MM/DD/YYYY'') "Date Received On"
            ,  TO_CHAR(A.NOTICE_DUE_ON,''MM/DD/YYYY'') "Date Due On"
            ,  TO_CHAR(A.NOTICE_REMINDER_ON,''MM/DD/YYYY'') "Date Reminder Set"
            ,  TO_CHAR(A.NOTICE_SENT_ON,''MM/DD/YYYY'') "Date Sent On"
            ,  B.NOTE||'' ''||A.DESCRIPTION "Benefit Plan Notes"
            , A.TEST_RESULT  "Discrimination Testing Result"
            , round(SYSDATE-B.PLAN_START_DATE) "Days Aging"
        FROM  PLAN_NOTICES A, BEN_PLAN_ENROLLMENT_SETUP B, ACCOUNT C
        WHERE NOTICE_TYPE IN (''1ST_QTR_NDT'',''LAST_QTR_NDT'')
        AND   A.ENTITY_ID = B.BEN_PLAN_ID
        AND   A.ENTITY_TYPE = ''BEN_PLAN_ENROLLMENT_SETUP''
        AND   B.ACC_ID= C.ACC_ID
        and   b.plan_end_date > sysdate ';


    dbms_output.put_line('sql '||l_sql);

     mail_utility.report_emails('oracle@sterlingadministration.com'
                             ,'compliance@sterlingadministration.com'
                           ,'compliance_ndt_tracking'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Non Discrimination Compliance Testing Tracking Report');
 --  END IF;
 exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END notify_comp_discrim_testing;
/*PROCEDURE process_new_ben_plans
IS
  L_TEMPLATE_SUBJECT varchar2(2000);
  L_template_body    varchar2(4000);
  l_role_count       NUMBER := 0;
  l_notif_id         NUMBER;
  num_tbl number_tbl;
BEGIN

  FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  TEMPLATE_NAME= 'ONLINE_ER_NEW_PLAN_APPROVAL'
              AND    STATUS = 'A')
  LOOP
     L_TEMPLATE_SUBJECT := X.template_subject;
     L_template_body    := X.template_body;
  END LOOP;


  FOR X IN (
                SELECT C.ENTRP_ID
                     , E.USER_ID
                     , E.EMAIL
                     , B.ACCOUNT_TYPE
                     , E.EMP_REG_TYPE
                FROM   BEN_PLAN_ENROLLMENT_SETUP A
                     , ACCOUNT B
                     , PERSON C
                     , ENTERPRISE D
                     , ONLINE_USERS E
                WHERE  A.STATUS = 'P'
                AND    A.ACC_ID = B.ACC_ID
                AND    C.PERS_ID = B.PERS_ID
                AND    C.entrp_id = d.entrp_id
                AND    REPLACE(D.ENTRP_CODE,'-') = E.TAX_ID
                and     E.EMP_REG_TYPE in (2,4)
                and     E.user_status='A'
                GROUP BY C.ENTRP_ID
                     , E.USER_ID
                     , E.EMAIL
                     , B.ACCOUNT_TYPE
                     , E.EMP_REG_TYPE
                HAVING COUNT(A.BEN_PLAN_ID) >= 1 )
  LOOP
        l_role_count := 0;
        l_notif_id   := NULL;

        IF X.EMP_REG_TYPE = 4 THEN
            SELECT  COUNT(*) INTO l_role_count
            FROM    USER_ROLE_ENTRIES B, SITE_NAVIGATION C
            WHERE   B.SITE_NAV_ID = C.SITE_NAV_ID
            AND     B.USER_ID = X.user_id
             and    c.NAV_CODE IN ('HRA_EE','FSA_EE');
        END IF;

        IF (X.EMP_REG_TYPE = 4 AND l_role_count > 0
        OR  X.EMP_REG_TYPE = 2)
        THEN
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
               (P_FROM_ADDRESS => 'clientservices@sterlingadministration.com'
               ,P_TO_ADDRESS   => x.email
               ,P_CC_ADDRESS   => 'clientservices@sterlingadministration.com'
               ,P_SUBJECT      => L_TEMPLATE_SUBJECT
               ,P_MESSAGE_BODY => L_template_body
               ,P_USER_ID      => X.user_id
               ,X_NOTIFICATION_ID => l_notif_id );

               num_tbl(1):=x.user_id;
               add_notify_users(num_tbl,l_notif_id);

               dbms_output.put_line('l_notif_id'||l_notif_id);
             UPDATE EMAIL_NOTIFICATIONS
          SET    MAIL_STATUS = 'READY'
            ,   ACC_ID = pc_entrp.get_acc_id(x.entrp_id)
          WHERE  NOTIFICATION_ID  = l_notif_id;
        END IF;

   END LOOP;
 END process_new_ben_plans;*/
 /*PROCEDURE process_qe_approval
IS
  L_TEMPLATE_SUBJECT varchar2(2000);
  L_template_body    varchar2(4000);
  l_role_count       NUMBER := 0;
  l_notif_id         NUMBER;
  num_tbl number_tbl;
BEGIN

  FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  TEMPLATE_NAME= 'ONLINE_ER_QE_CR_APPROVAL'
              AND    STATUS = 'A')
  LOOP
     L_TEMPLATE_SUBJECT := X.template_subject;
     L_template_body    := X.template_body;
  END LOOP;


  FOR X IN (
                SELECT d.ENTRP_ID
                     , E.USER_ID
                     , E.EMAIL
                     , B.ACCOUNT_TYPE
                     , E.EMP_REG_TYPE
                FROM   BEN_LIFE_EVENT_HISTORY A
                     , ACCOUNT B
                     , ENTERPRISE D
                     , ONLINE_USERS E
                WHERE  A.STATUS = 'P'
                AND    A.ACC_ID = B.ACC_ID
                AND    a.entrp_id = d.entrp_id
                AND    REPLACE(D.ENTRP_CODE,'-') = E.TAX_ID
                 and     E.EMP_REG_TYPE in (2,4)
                  and     E.user_status='A'
                GROUP BY D.ENTRP_ID
                     , E.USER_ID
                     , E.EMAIL
                     , B.ACCOUNT_TYPE
                     , E.EMP_REG_TYPE
                HAVING COUNT(A.BEN_PLAN_ID) > 1 )
  LOOP
        l_role_count := 0;
        l_notif_id   := NULL;
        IF X.EMP_REG_TYPE = 4 THEN
            SELECT  COUNT(*) INTO l_role_count
            FROM    USER_ROLE_ENTRIES B, SITE_NAVIGATION C
            WHERE   B.SITE_NAV_ID = C.SITE_NAV_ID
            AND     B.USER_ID = x.user_id
             and    c.NAV_CODE IN ('HRA_EE','FSA_EE');
        END IF;

        IF (X.EMP_REG_TYPE = 4 AND l_role_count > 0
        OR  X.EMP_REG_TYPE = 2)
        THEN
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
               (P_FROM_ADDRESS => 'clientservices@sterlingadministration.com'
               ,P_TO_ADDRESS   => x.email
               ,P_CC_ADDRESS   => 'clientservices@sterlingadministration.com'
               ,P_SUBJECT      => L_TEMPLATE_SUBJECT
               ,P_MESSAGE_BODY => L_template_body
               ,P_USER_ID      => X.user_id
               ,X_NOTIFICATION_ID => l_notif_id );

               num_tbl(1):=x.user_id;
               add_notify_users(num_tbl,l_notif_id);

          UPDATE EMAIL_NOTIFICATIONS
          SET    MAIL_STATUS = 'READY'
            ,   ACC_ID = pc_entrp.get_acc_id(x.entrp_id)
          WHERE  NOTIFICATION_ID  = l_notif_id;
         END IF;
   END LOOP;
 END process_qe_approval;*/

 PROCEDURE List_pending_claims
    IS
      l_sql VARCHAR2(3200);
    BEGIN
         l_sql := 'SELECT ACC_NUM, DEBIT_CARD,PENDING_CLAIM
                 FROM ( SELECT DISTINCT acc.acc_num,
                     (SELECT COUNT(*) FROM CLAIMN WHERE PAY_REASON = 13 AND PERS_ID = P.PERS_ID AND UNSUBSTANTIATED_FLAG = ''Y'') DEBIT_CARD,
                    (SELECT COUNT(*) FROM CLAIMN WHERE PAY_REASON = 13 AND PERS_ID = P.PERS_ID AND CLAIM_STATUS = ''PENDING_REVIEW''
                     AND SERVICE_TYPE IN (''HRA'',''HRP'',''ACO'',''HR4'',''HR5'',''FSA'',''LPF'')) PENDING_CLAIM
               FROM ACCOUNT ACC, PERSON P, EOB_HEADER EB,ONLINE_USERS OU
            WHERE   OU.TAX_ID = REPLACE(P.SSN,''-'')
            AND ACC.PERS_ID = P.PERS_ID
            AND EB.USER_ID= OU.USER_ID
            AND OU.USER_STATUS = ''A''
            AND EB.CLAIM_ID IS NULL
            and acc.account_type IN (''HRA'',''FSA''))
            WHERE DEBIT_CARD+PENDING_CLAIM > 0' ;

    --dbms_output.put_line('SQL..'||l_sql);
         mail_utility.report_emails('oracle@sterlingadministration.com'
                               ,'benefits@sterlingadministration.com,techlog@sterlingadministration.com'
                               --,'puja.ghosh@sterlingadministration.com'
                               ,'list_pending_claims'||to_char(sysdate,'MMDDYYYY')||'.xls'
                               , l_sql
                               , NULL
                               , 'List of Outstanding Claims');
     EXCEPTION
      WHEN OTHERS THEN
    -- Close the file if something goes wrong.

        dbms_output.put_line('error message '||SQLERRM);
    END list_pending_claims;
         PROCEDURE ADD_NOTIFY_USERS
    ( P_USER_ID           IN NUMBER_TBL
    , P_NOTIFICATION_ID   IN NUMBER)
    IS
    BEGIN
        FORALL i IN P_USER_ID.FIRST .. P_USER_ID.LAST
          INSERT INTO notif_participants
          ( USER_ID
          , NOTIFICATION_ID
          , STATUS
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY)
            VALUES
          ( P_USER_ID(i)
          , P_NOTIFICATION_ID
          , 'UNREAD'
          , SYSDATE
          , GET_USER_ID(v('APP_USER'))
          , SYSDATE
          , GET_USER_ID(v('APP_USER')));
    END;

     FUNCTION GET_MESSAGE_CENTER
    (P_USER_ID  IN  NUMBER,P_ACC_ID NUMBER)
    RETURN NOTIFICATION_T PIPELINED DETERMINISTIC IS
     L_RECORD    NOTIFICATION_REC;
    BEGIN

pc_log.log_error('In GET_MESSAGE_CENTER..P_ACC_ID ',P_ACC_ID||' P_USER_ID :='||P_USER_ID);
            FOR X IN (SELECT EN.NOTIFICATION_ID
                           , NP.USER_ID
                           , EN.SUBJECT
                           , EN.MESSAGE_BODY
                           , NP.STATUS
                         --, TO_CHAR(EN.CREATION_DATE,'MM/DD/YYYY') CREATION_DATE
                           , EN.CREATION_DATE
                        FROM EMAIL_NOTIFICATIONS EN
                           , NOTIF_PARTICIPANTS NP
                       WHERE EN.NOTIFICATION_ID = NP.NOTIFICATION_ID--(+)
                         and ((user_id in (select user_id from online_users where tax_id=(select tax_id from online_users where user_id=p_user_id)))
                              OR (user_id = 0))  -- OR added by Swamy for Ticket#12681
                         and en.creation_date>sysdate-15
                         AND (ACC_ID             = P_ACC_ID )
                    ORDER BY EN.CREATION_DATE DESC)
            LOOP
                    L_RECORD.SUBJECT           := X.SUBJECT;
                    L_RECORD.MESSAGE_BODY      := X.MESSAGE_BODY;
                    L_RECORD.STATUS            := X.STATUS;
                    L_RECORD.NOTIFICATION_ID   := X.NOTIFICATION_ID;
                    L_RECORD.USER_ID           := X.USER_ID;
                    L_RECORD.NOTIFICATION_DATE := X.CREATION_DATE;

              PIPE ROW (L_RECORD);
            END LOOP;

     END GET_MESSAGE_CENTER;

    FUNCTION GET_MESSAGE_BODY
    (P_NOTIFICATION_ID  IN  NUMBER)
    RETURN NOTIFICATION_T PIPELINED DETERMINISTIC IS
     L_RECORD    NOTIFICATION_REC;
    BEGIN
      FOR X IN (SELECT NOTIFICATION_ID
                     , SUBJECT
                     , MESSAGE_BODY
                     , mail_STATUS
                   --, TO_CHAR(EN.CREATION_DATE,'MM/DD/YYYY') CREATION_DATE
                     , CREATION_DATE
                  FROM EMAIL_NOTIFICATIONS
                 WHERE NOTIFICATION_ID = P_NOTIFICATION_ID
              ORDER BY CREATION_DATE DESC)
      LOOP
              L_RECORD.SUBJECT           := X.SUBJECT;
              L_RECORD.MESSAGE_BODY      := X.MESSAGE_BODY;
              L_RECORD.STATUS            := X.mail_STATUS;
              L_RECORD.NOTIFICATION_ID   := X.NOTIFICATION_ID;
              L_RECORD.NOTIFICATION_DATE := X.CREATION_DATE;

        PIPE ROW (L_RECORD);
      END LOOP;
    END GET_MESSAGE_BODY;

  PROCEDURE update_notif_participants (P_NOTIFICATION_ID IN NUMBER,P_USER_ID IN VARCHAR2,P_status IN VARCHAR2)
    IS
  BEGIN
     if p_status in('READ','UNREAD')then
     UPDATE NOTIF_PARTICIPANTS
     SET STATUS=p_status,
     status_change_date=sysdate
     WHERE NOTIFICATION_ID = P_NOTIFICATION_ID
     AND USER_ID = P_USER_ID;
     end if;
  END update_notif_participants;

  PROCEDURE delete_notif_participants (P_NOTIFICATION_ID IN NUMBER,P_USER_ID IN VARCHAR2)
    IS
  BEGIN
     DELETE NOTIF_PARTICIPANTS
     WHERE NOTIFICATION_ID = P_NOTIFICATION_ID
     AND USER_ID = P_USER_ID;
  END delete_notif_participants;
  function get_invoice_notifications (p_invoice_id    IN NUMBER  ,p_invoice_reason IN VARCHAR2
                                      ,p_template_name IN VARCHAR2,p_notify_type    IN VARCHAR2)
  RETURN notify_t PIPELINED DETERMINISTIC
  IS
       l_record_t               notify_row_t;

  BEGIN

     FOR X IN (
       SELECT   c.TEMPLATE_SUBJECT SUBJECT
                 , a.invoice_id
                 , d.entrp_code
                 , d.name
                 , a.acc_num
                 , REPLACE(REPLACE(REPLACE(c.template_body,'<<PLAN_TYPE>>', A.PLAN_TYPE)
                                          ,'<<INVOICE_DUE_DATE>>', TO_CHAR(a.invoice_due_date,'MM/DD/YYYY'))
                                          ,'<<INVOICE_DATE>>',TO_CHAR(START_DATE,'MM/DD/YYYY') ||'-'||TO_CHAR(END_DATE,'MM/DD/YYYY')
                                          ) BODY
        from   ar_invoice a, invoice_parameters b,notification_template c,enterprise d
        where  a.invoice_id = p_invoice_id
        and    a.entity_id = b.entity_id
        and    a.entity_type = b.entity_type
        and    a.entity_id = d.entrp_id
        and    a.invoice_reason = b.invoice_type
        and    a.invoice_reason = p_invoice_reason
        and    a.payment_method is NOT NULL
        and    a.invoice_due_date IS NOT NULL
        AND    a.rate_plan_id = b.rate_plan_id --Added by Joshi 6708.
        AND    b.status  = 'A'
         and   ( (p_notify_type = 'FEE_INVOICE' and TRUNC(a.APPROVED_DATE) >= trunc(SYSDATE,'MM'))
               OR (p_notify_type <>  'FEE_INVOICE' and TRUNC(a.APPROVED_DATE) is not null))
        and    a.mailed_date is null
        and   ( (p_notify_type = 'CLAIM_INVOICE'
                  and    ((a.payment_method = 'DIRECT_DEPOSIT' AND c.template_name ='CLAIM_INVOICE_ACH_EMAIL')
                          OR   (a.payment_method IN ('CHECK','ACH_PUSH') AND c.template_name ='CLAIM_INVOICE_CHECK_EMAIL')))
           OR   (p_notify_type = 'COMPLIANCE_FEE_INVOICE'
                  and    ((a.payment_method = 'DIRECT_DEPOSIT' AND c.template_name ='INVOICE_NOTIFY_ACH_EMAIL')
                          OR   (a.payment_method IN ('CHECK','ACH_PUSH') AND c.template_name ='INVOICE_NOTIFY_REMIT_EMAIL')))
           OR   (p_notify_type = 'FEE_INVOICE'
                and    ((a.payment_method = 'DIRECT_DEPOSIT' AND c.template_name ='INVOICE_ACH_EMAIL')
                          OR  ( a.payment_method IN ('CHECK','ACH_PUSH') AND c.template_name ='INVOICE_CHECK_EMAIL')))
           OR   (p_notify_type = 'FUND_INVOICE'
                and    ((a.payment_method = 'DIRECT_DEPOSIT' AND c.template_name ='FUNDING_INVOICE_ACH_EMAIL')
                          OR  ( a.payment_method IN ('CHECK','ACH_PUSH') AND c.template_name ='FUNDING_INVOICE_CHECK_EMAIL')))


        ))
    LOOP
       l_record_t.SUBJECT := x.SUBJECT;
       l_record_t.person_name := x.name;
       l_record_t.acc_num := x.acc_num;
       l_record_t.email_body := x.BODY;
       l_record_t.ein := x.entrp_code;

       FOR XX IN ( SELECT email
                         FROM CONTACT a , ar_invoice_contacts b
                   WHERE B.invoice_id = p_invoice_id
                    AND  a.contact_id = b.contact_id
                    AND nvl(a.status,'A') = 'A' and a.end_date is null
                    AND  A.CAN_CONTACT = 'Y' )
           LOOP
              IF  l_record_t.email IS NULL THEN
                    l_record_t.email := xx.email;

            ELSE
                    l_record_t.email := l_record_t.email||','||xx.email;

            END IF;
           END LOOP;

       PIPE ROW (l_record_t);

    END LOOP;



 END get_invoice_notifications;
  -- Called from the web for all enrollment express notifications
 PROCEDURE insert_web_notification
    (P_FROM_ADDRESS IN VARCHAR2
    ,P_TO_ADDRESS   IN VARCHAR2
    ,P_SUBJECT      IN VARCHAR2
    ,P_MESSAGE_BODY IN VARCHAR2
    ,P_USER_ID      IN NUMBER
    ,P_ACC_ID       IN NUMBER)
IS
    pragma autonomous_transaction;
    l_notif_id NUMBER;
    num_tbl    PC_NOTIFICATIONS.number_tbl;
BEGIN
  PC_NOTIFICATIONS.INSERT_NOTIFICATIONs
     (P_FROM_ADDRESS    => P_FROM_ADDRESS
     ,P_TO_ADDRESS      => P_TO_ADDRESS
     ,P_CC_ADDRESS      => P_FROM_ADDRESS
     ,P_SUBJECT         => P_SUBJECT
     ,P_MESSAGE_BODY    => P_MESSAGE_BODY
     ,P_USER_ID         => P_USER_ID
     ,P_ACC_ID          => P_ACC_ID
     ,X_NOTIFICATION_ID => l_notif_id );
   num_tbl(1) := P_USER_ID;
   PC_NOTIFICATIONS.add_notify_users(num_tbl,l_notif_id);
   UPDATE EMAIL_NOTIFICATIONS
    SET   mail_STATUS = 'SENT' WHERE NOTIFICATION_ID = l_notif_id;
  commit;
END insert_web_notification;

 -- Called from the web for all enrollment express notifications with overloading option having event and batch number
 PROCEDURE INSERT_WEB_NOTIFICATION
    (P_FROM_ADDRESS IN VARCHAR2
    ,P_TO_ADDRESS   IN VARCHAR2
    ,P_SUBJECT      IN VARCHAR2
    ,P_MESSAGE_BODY IN VARCHAR2
    ,P_USER_ID      IN NUMBER
    ,P_ACC_ID       IN NUMBER
    ,P_EVENT        IN VARCHAR2
    ,P_BATCH_NUM    IN VARCHAR2 ) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    L_NOTIF_ID   NUMBER;
    NUM_TBL      PC_NOTIFICATIONS.NUMBER_TBL;
  BEGIN
     IF P_TO_ADDRESS IS NOT NULL THEN
        INSERT INTO EMAIL_NOTIFICATIONS
              (NOTIFICATION_ID
              ,FROM_ADDRESS
              ,TO_ADDRESS
              ,CC_ADDRESS
              ,SUBJECT
              ,MESSAGE_BODY
              ,MAIL_STATUS
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,ACC_ID
              ,BATCH_NUM
              ,EVENT)
          VALUES
              (NOTIFICATION_SEQ.NEXTVAL
              ,P_FROM_ADDRESS
              ,P_TO_ADDRESS
              ,P_FROM_ADDRESS
              ,P_SUBJECT
              ,P_MESSAGE_BODY
              ,'OPEN'
              ,SYSDATE
              ,P_USER_ID
              ,SYSDATE
              ,P_USER_ID
              ,P_ACC_ID
              ,P_BATCH_NUM
              ,P_EVENT)
              RETURNING NOTIFICATION_ID INTO L_NOTIF_ID;
     END IF;

     NUM_TBL(1) := P_USER_ID;

     PC_NOTIFICATIONS.ADD_NOTIFY_USERS(NUM_TBL,L_NOTIF_ID);

     UPDATE EMAIL_NOTIFICATIONS
        SET MAIL_STATUS = 'SENT'
      WHERE NOTIFICATION_ID = L_NOTIF_ID;
    COMMIT;
  END INSERT_WEB_NOTIFICATION;
  /*
  procedure hsa_oversubscribe_notification(p_acc_id number,p_year varchar2)is
  l_notif_id number;
  num_tbl number_tbl;
  p_effective_date date:=to_date(to_char(sysdate,'ddmm')||substr(p_year,-2),'ddmmrr');
  begin
  FOR X IN(SELECT template_subject,template_body,to_address,cc_address
   FROM NOTIFICATION_TEMPLATE
  WHERE NOTIFICATION_TYPE = 'EXTERNAL'
    AND TEMPLATE_NAME  = 'HSA_OVERSUBSCRIBED'
    AND STATUS = 'A')
  LOOP
   FOR XX IN(SELECT PC_PERSON.GET_PERSON_NAME(a.PERS_ID)NAME,EMAIL,acc_num,
   pc_users.get_user(ssn)user_id,
   pc_account.year_income(acc_id,p_effective_date)contb
    FROM PERSON a,account b
   WHERE a.pers_id = b.pers_id
     and acc_id = p_acc_id)
   LOOP
    pc_notifications.insert_notifications
    (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
    ,P_TO_ADDRESS      => xx.email
    ,P_CC_ADDRESS      => x.cc_address
    ,P_SUBJECT         => replace(x.template_subject,'<>',xx.acc_num)
    ,P_MESSAGE_BODY    => x.template_body
    ,P_USER_ID         => xx.user_id
    ,X_NOTIFICATION_ID => l_notif_id );
    num_tbl(1) := xx.user_id;
    add_notify_users(num_tbl,l_notif_id);
    PC_NOTIFICATIONS.SET_TOKEN('ACCOUNTHOLDER_NAME',xx.name, l_notif_id);
    PC_NOTIFICATIONS.SET_TOKEN('CONTRIBUTION',      xx.contb,l_notif_id);
  end loop;

        UPDATE EMAIL_NOTIFICATIONS
       SET    MAIL_STATUS = 'READY'
         ,    acc_id = p_acc_id
       WHERE  NOTIFICATION_ID  = l_notif_id;
   END LOOP;
   exception
   WHEN OTHERS THEN
    dbms_output.put_line('error message '||SQLERRM);
END;

  procedure notify_hsa_oversubscribed(p_year varchar2) is
  begin
  for x in(select acc_id from account where account_type='HSA'and pc_account.is_hsa_oversubscribed(acc_id,p_year)='Y')
  loop
   pc_notifications.hsa_oversubscribe_notification(x.acc_id,p_year);
  end loop;
  end;
  */

  PROCEDURE SET_TOKEN_SUBJECT (p_token    IN VARCHAR2
                              ,p_string   IN VARCHAR2
                              ,p_notif_id IN NUMBER)
  IS
  BEGIN
     UPDATE EMAIL_NOTIFICATIONS
        SET SUBJECT = REPLACE(SUBJECT,'<<'||P_TOKEN||'>>',P_STRING)
      WHERE notification_id =p_notif_id;
  END SET_TOKEN_SUBJECT;

  PROCEDURE INSERT_NOTIFICATIONS
   (P_FROM_ADDRESS IN VARCHAR2
   ,P_TO_ADDRESS   IN VARCHAR2
   ,P_CC_ADDRESS   IN VARCHAR2
   ,P_SUBJECT      IN VARCHAR2
   ,P_MESSAGE_BODY IN VARCHAR2
   ,P_USER_ID      IN NUMBER
   ,P_EVENT        IN VARCHAR2
   ,P_ACC_ID       IN NUMBER DEFAULT NULL
   ,X_NOTIFICATION_ID OUT NUMBER)
      IS
   BEGIN dbms_output.put_line('insrt');
     IF p_to_address IS NOT NULL THEN
          INSERT INTO EMAIL_NOTIFICATIONS
          (NOTIFICATION_ID
          ,FROM_ADDRESS
          ,TO_ADDRESS
          ,CC_ADDRESS
          ,SUBJECT
          ,MESSAGE_BODY
          ,MAIL_STATUS
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,ACC_ID
          ,EVENT)
          VALUES
          (NOTIFICATION_SEQ.NEXTVAL
          ,P_FROM_ADDRESS
          ,P_TO_ADDRESS
          ,P_CC_ADDRESS
          ,P_SUBJECT
          ,P_MESSAGE_BODY
          ,'OPEN'
          ,SYSDATE
          ,P_USER_ID
          ,SYSDATE
          ,P_USER_ID
          ,P_ACC_ID
          ,P_EVENT) RETURNING NOTIFICATION_ID INTO X_NOTIFICATION_ID;
     END IF;
     exception when others then dbms_output.put_line(sqlerrm);
   END INSERT_NOTIFICATIONS;

  PROCEDURE NOTIFY_ER_REN_DECL_PLAN(P_ACC_ID       IN VARCHAR2,
                                    P_ENAME        IN VARCHAR2,
                                    P_EMAIL        IN VARCHAR2,
                                    P_USER_ID      IN VARCHAR2,
                                    P_ENTRP_ID     IN VARCHAR2,
                                    P_BEN_PLAN_ID  IN VARCHAR2,
                                    P_BEN_PLN_NAME IN VARCHAR2,
                                    P_REN_DEC_FLG  IN VARCHAR2,
                                    P_ACC_NUM      IN VARCHAR2
                                    --P_PAY_ACCT_FEES IN VARCHAR2 DEFAULT NULL
                                    ) IS
     L_NOTIFICATION_ID    NUMBER;
     L_NUM_TBL            PC_NOTIFICATIONS.NUMBER_TBL;
     L_SALES_REP_EMAIL    VARCHAR2(4000);
     L_EMAIL              VARCHAR2(4000);
     L_ENTRP_EMAIL        VARCHAR2(4000);
     L_EMAIL_CSS          VARCHAR2(4000);
     L_TO_ADDRESS         VARCHAR2(4000);
     L_CC_ADDRESS         VARCHAR2(4000);
     l_account_type varchar2(100):=pc_account.get_account_type(p_acc_id);
     L_plan_type Varchar2(100); -- ticket# 5085
     num_tbl number_tbl;
    -- l_TEMPLATE_NAME      VARCHAR2(100);
  --   l_name               VARCHAR2(500);
 --    l_PAY_ACCT_FEES      VARCHAR2(100);

  BEGIN
     L_TO_ADDRESS  := NULL;
     L_CC_ADDRESS := NULL;

     FOR K IN (SELECT PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(ENTRP_CODE,'-')) SUPER_ADMIN_EMAIL
                 FROM ENTERPRISE A
                WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
         L_TO_ADDRESS := K.SUPER_ADMIN_EMAIL;
     END LOOP;

     L_SALES_REP_EMAIL := PC_CONTACT.GET_SALESREP_EMAIL(P_ENTRP_ID) ;
     if L_SALES_REP_EMAIL IS NOT NULL THEN
        L_CC_ADDRESS := L_SALES_REP_EMAIL;
     END IF;

 /*  FOR j IN (SELECT a.ACCOUNT_TYPE,b.name,DECODE(P_PAY_ACCT_FEES,'GA','General Agent','BROKER','Broker','EMPLOYER','Employer') PAY_ACCT_FEES
              FROM account a,enterprise b
             WHERE a.acc_id = p_acc_id
               AND a.entrp_id = b.entrp_id) LOOP
     l_name           := j.name;
     l_PAY_ACCT_FEES  := j.PAY_ACCT_FEES;
   END LOOP;

   IF l_account_type = 'COBRA' THEN      -- Added by Swamy for Ticket#11364
      l_TEMPLATE_NAME := 'BROKER_PLAN_RENEWAL_ONLINE_COBRA';
   ELSE
      l_TEMPLATE_NAME := 'BROKER_PLAN_RENEWAL_ONLINE';
   END IF;
*/
     IF P_REN_DEC_FLG = 'R' THEN
        FOR I IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         NVL(A.CC_ADDRESS, CASE WHEN l_account_type IN ('FSA', 'HRA') THEN
                                                'clientservices@sterlingadministration.com'
                                               WHEN l_account_type = 'COBRA' THEN
                                               'cobra@sterlingadministration.com'
                                               WHEN l_account_type IN ('ERISA_WRAP','POP','FORM_5500') THEN
                                               'compliance@sterlingadministration.com'
                                               ELSE
                                                'customer.service@sterlingadministration.com' end) CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'EMPLOYER_PLAN_RENEWAL_ONLINE'
                     AND A.STATUS        = 'A') LOOP


             IF USER <> 'SAM' THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
                L_CC_ADDRESS := null;
             ELSE

                L_CC_ADDRESS := CASE WHEN L_CC_ADDRESS IS NULL THEN I.CC_ADDRESS
                                     ELSE L_CC_ADDRESS||','||I.CC_ADDRESS END;
             END IF;

              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS--||', '||L_EMAIL_CSS
                           ,P_CC_ADDRESS      => L_CC_ADDRESS--I.CC_ADDRESS
                           ,P_SUBJECT         => replace(I.TEMPLATE_SUBJECT,'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => I.TEMPLATE_BODY
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'EMPLOYER_PLAN_RENEWAL_ONLINE'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

              PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',P_ENAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,l_account_type),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('DATE',TO_CHAR(SYSDATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN_SUBJECT ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
            --  PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',l_name,L_NOTIFICATION_ID);           -- Added by Swamy for Ticket#11364
          --    PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_TYPE',l_account_type,L_NOTIFICATION_ID);     -- Added by Swamy for Ticket#11364
          --    PC_NOTIFICATIONS.SET_TOKEN ('PAY_ACCT_FEES',l_PAY_ACCT_FEES,L_NOTIFICATION_ID);   -- Added by Swamy for Ticket#11364

              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

             UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     ELSIF P_REN_DEC_FLG = 'D' THEN
        FOR I IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         NVL(A.CC_ADDRESS, CASE WHEN l_account_type IN ('FSA', 'HRA') THEN
                                                'clientservices@sterlingadministration.com'
                                               WHEN l_account_type = 'COBRA' THEN
                                               'cobra@sterlingadministration.com'
                                               WHEN l_account_type IN ('ERISA_WRAP','POP','FORM_5500') THEN
                                               'compliance@sterlingadministration.com'
                                               ELSE
                                                'customer.service@sterlingadministration.com' end) CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'EMPLOYER_PLAN_DECLINE_ONLINE'
                     AND A.STATUS = 'A') LOOP

             IF USER <> 'SAM' THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
                L_CC_ADDRESS := null;
             ELSE
                L_CC_ADDRESS := CASE WHEN L_CC_ADDRESS IS NULL THEN I.CC_ADDRESS
                                     ELSE L_CC_ADDRESS||','||I.CC_ADDRESS END;
             END IF;

              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS
                           ,P_CC_ADDRESS      => L_CC_ADDRESS--I.CC_ADDRESS
                           ,P_SUBJECT         => replace(I.TEMPLATE_SUBJECT,'<<EMPLOYER_NAME>>',p_acc_num||' '||pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => I.TEMPLATE_BODY
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'EMPLOYER_PLAN_DECLINE_ONLINE'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

              PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',P_ENAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
       If l_account_type  IN ('FSA', 'HRA') THEN --- ticket 5085 Added by rprabu on 15/03/2019
        Begin
            select plan_type Into  L_plan_type
             from ben_plan_enrollment_setup
            Where ben_plan_id = P_BEN_PLAN_ID;
            PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,L_plan_type),L_NOTIFICATION_ID);
         Exception when No_data_found Then
            PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,l_account_type),L_NOTIFICATION_ID );
          End;
      Else
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,l_account_type),L_NOTIFICATION_ID);
      End if;   --- End ticket 5085
       --       PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,l_account_type),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('DATE',TO_CHAR(SYSDATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN_SUBJECT ('EMPLOYER_NAME',P_ENAME,L_NOTIFICATION_ID);
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;

        END LOOP;
     END IF;
  END NOTIFY_ER_REN_DECL_PLAN;

 PROCEDURE NOTIFY_ER_HRA_FSA_PLAN_RENEW(P_ACC_ID       IN VARCHAR2,
                                         P_PLAN_TYPE    IN VARCHAR2,
                                         P_ACC_NUM      IN VARCHAR2,
                                         P_BEN_PLAN_ID  IN VARCHAR2,
                                         P_PRODUCT_TYPE IN VARCHAR2,
                                         P_USER_ID      IN VARCHAR2,
                                         P_ENTRP_ID     IN VARCHAR2) IS
     L_NOTIFICATION_ID    NUMBER;
     L_TEMPLATE_SUB       VARCHAR2(4000);
     L_TEMPLATE_BOD       VARCHAR2(4000);
     L_CC_EMAIL           VARCHAR2(4000);
     L_NAME               VARCHAR2(4000);
     L_ADDRESS            VARCHAR2(4000);
     L_ADDRESS2           VARCHAR2(4000);
     L_ENTRP_EMAIL        VARCHAR2(4000);
     L_EMAIL              VARCHAR2(4000);
     L_COVERAGE_TYPE1     VARCHAR2(4000);
     L_COVERAGE_TYPE2     VARCHAR2(4000);
     L_COVERAGE_TYPE3     VARCHAR2(4000);
     L_DEDUCTIBLE1        VARCHAR2(4000);
     L_ROLLOVER1          VARCHAR2(4000);
     L_DEDUCTIBLE2        VARCHAR2(4000);
     L_ROLLOVER2          VARCHAR2(4000);
     L_DEDUCTIBLE3        VARCHAR2(4000);
     L_ROLLOVER3          VARCHAR2(4000);
     num_tbl number_tbl;
     L_TO_ADDRESS         VARCHAR2(4000);
     L_CC_ADDRESS         VARCHAR2(4000);
     L_SALES_REP_EMAIL    VARCHAR2(4000);

  BEGIN
     L_TO_ADDRESS  := NULL;
     L_CC_ADDRESS := NULL;

     FOR K IN (SELECT PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(ENTRP_CODE,'-')) SUPER_ADMIN_EMAIL
                 FROM ENTERPRISE A
                WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
         L_TO_ADDRESS := K.SUPER_ADMIN_EMAIL;
     END LOOP;
     L_CC_ADDRESS := 'clientservices@sterlingadministration.com';

    L_SALES_REP_EMAIL := PC_CONTACT.GET_SALESREP_EMAIL(P_ENTRP_ID) ;
     if L_SALES_REP_EMAIL IS NOT NULL THEN
        L_CC_ADDRESS := L_CC_ADDRESS||','||L_SALES_REP_EMAIL;
     END IF;


     IF P_PRODUCT_TYPE = 'FSA' THEN
        L_TEMPLATE_SUB := NULL;
        L_TEMPLATE_BOD := NULL;

        FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         A.CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'EMPLOYER_ONLINE_RENEWAL_FSA'
                     AND A.STATUS = 'A') LOOP
            L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
            L_TEMPLATE_BOD := J.TEMPLATE_BODY;
            if J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
        END LOOP;

        FOR K IN (SELECT A.NAME,
                         A.ADDRESS,
                         A.CITY||' '||A.STATE||' '||A.ZIP ADDRESS2,
                         A.ENTRP_EMAIL
                    FROM ENTERPRISE A
                   WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
            L_NAME        := K.NAME;
            L_ADDRESS     := K.ADDRESS;
            L_ADDRESS2    := K.ADDRESS2;
            L_ENTRP_EMAIL := K.ENTRP_EMAIL;
        END LOOP;

       IF USER <> 'SAM' THEN
       --IF USER NOT IN ('SAM','SAMQA','SAMDEMO') THEN
          L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
          L_CC_ADDRESS := null;
       END IF;


        FOR I IN (SELECT A.*
                    FROM BEN_PLAN_ENROLLMENT_SETUP A
                   WHERE BEN_PLAN_ID = P_BEN_PLAN_ID) LOOP

              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS--NVL(L_EMAIL,L_ENTRP_EMAIL)
                           ,P_CC_ADDRESS      => L_CC_ADDRESS--L_CC_EMAIL
                           ,P_SUBJECT         => replace(replace(L_TEMPLATE_SUB,'<<ACCOUNT>>',p_acc_num),'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => L_TEMPLATE_BOD
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'EMPLOYER_ONLINE_RENEWAL_FSA'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );
              dbms_output.put_line(L_NOTIFICATION_ID);
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              PC_NOTIFICATIONS.SET_TOKEN ('RENEWAL_DATE',TO_CHAR(I.RENEWAL_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_NAME',L_NAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD1',L_ADDRESS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD2',L_ADDRESS2,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,L_NOTIFICATION_ID);

              /* Ticket#5168.Hard coded ; has been removed */
              IF I.PLAN_TYPE = 'FSA' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('HEALTHCARE_FSA_H','<b>Healthcare FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H','Annual Election : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H','Funding : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H','Rollover : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H','Grace : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H','Runout : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H','Non-Discrimination Testing : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'FSA_FUNDING_OPTION')||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER',I.ROLLOVER||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE',I.GRACE_PERIOD||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT',I.RUNOUT_PERIOD_DAYS||' '||I.RUNOUT_PERIOD_TERM||'</br>',L_NOTIFICATION_ID);
                 --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCR',I.NON_DISCRM_FLAG||'</br>'||'</br>',L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('HEALTHCARE_FSA_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT','',L_NOTIFICATION_ID);
                 --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCR','',L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861
              END IF;

              IF I.PLAN_TYPE = 'LPF' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('LIMITED_PURPOSE_FSA_H','<b>Limited Purpose FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H1','Annual Election : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H1','Funding : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H1','Rollover : ' ,L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H1','Grace : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H1','Runout : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H1','Non-Discrimination Testing : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_1',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_1',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'FSA_FUNDING_OPTION')||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_1',I.ROLLOVER||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_1',I.GRACE_PERIOD||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_1',I.RUNOUT_PERIOD_DAYS||' '||I.RUNOUT_PERIOD_TERM||'</br>',L_NOTIFICATION_ID);
                 --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCR_1',I.NON_DISCRM_FLAG||'</br>'||'</br>',L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('LIMITED_PURPOSE_FSA_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H1','' ,L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_1','',L_NOTIFICATION_ID);
                 --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCR_1','',L_NOTIFICATION_ID);   -- Commented by Swamy for Ticket#9861
              END IF;

              IF I.PLAN_TYPE = 'DCA' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('DEPENDENT_CARE_FSA','<b>Dependent Care FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_2',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>'||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H2','Annual Election : ',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('DEPENDENT_CARE_FSA','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H2','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'TRN' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('TRANSIT_FSA', '<b>Transit FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('TRANSIT_FSA','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'PKG' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('PARKING_FSA','<b>Parking FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('PARKING_FSA','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'UA1' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('BIKE_FSA','<b>Bike FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('BIKE_FSA','',L_NOTIFICATION_ID);
              END IF;

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS     = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     ELSIF P_PRODUCT_TYPE = 'HRA' THEN
        L_TEMPLATE_SUB := NULL;
        L_TEMPLATE_BOD := NULL;

        FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         A.CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'EMPLOYER_ONLINE_RENEWAL_HRA'
                     AND A.STATUS = 'A') LOOP
            L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
            L_TEMPLATE_BOD := J.TEMPLATE_BODY;
           if J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
         END LOOP;

        FOR K IN (SELECT A.NAME,
                         A.ADDRESS,
                         A.CITY||' '||A.STATE||' '||A.ZIP ADDRESS2,
                         A.ENTRP_EMAIL
                    FROM ENTERPRISE A
                   WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
            L_NAME      := K.NAME;
            L_ADDRESS   := K.ADDRESS;
            L_ADDRESS2  := K.ADDRESS2;
            L_ENTRP_EMAIL := K.ENTRP_EMAIL;
        END LOOP;

        FOR I IN (SELECT RENEWAL_DATE,
                         DECODE (NEW_HIRE_CONTRIB, 'PRORATE', 'Y', 'N') NEW_HIRE_CONTRIB,
                         NON_DISCRM_FLAG,
                         PLAN_START_DATE,
                         PLAN_END_DATE,
                         RUNOUT_PERIOD_DAYS,
                         EOB_REQUIRED,
                         FUNDING_OPTIONS
                    FROM BEN_PLAN_ENROLLMENT_SETUP A
                   WHERE BEN_PLAN_ID = P_BEN_PLAN_ID) LOOP
              L_COVERAGE_TYPE1  := NULL;
              L_COVERAGE_TYPE2  := NULL;
              L_COVERAGE_TYPE3  := NULL;
              L_ROLLOVER1       := NULL;
              L_ROLLOVER2       := NULL;
              L_ROLLOVER3       := NULL;
              L_DEDUCTIBLE1     := NULL;
              L_DEDUCTIBLE2     := NULL;
              L_DEDUCTIBLE3     := NULL;


              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => l_to_address--NVL(L_EMAIL,L_ENTRP_EMAIL)
                           ,P_CC_ADDRESS      => l_cc_address--L_CC_EMAIL
                           ,P_SUBJECT         => replace(replace(L_TEMPLATE_SUB,'<<ACCOUNT>>',p_acc_num),'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => L_TEMPLATE_BOD
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'EMPLOYER_ONLINE_RENEWAL_HRA'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              PC_NOTIFICATIONS.SET_TOKEN ('RENEWAL_DATE',TO_CHAR(I.RENEWAL_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_NAME',L_NAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD1',L_ADDRESS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD2',L_ADDRESS2,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_OPT',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'HRA_FUNDING_OPTION'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('RUN_OUT',I.RUNOUT_PERIOD_DAYS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('EOB',I.EOB_REQUIRED,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PRORATE',I.NEW_HIRE_CONTRIB,L_NOTIFICATION_ID);
              --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCR',I.NON_DISCRM_FLAG,L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE =  'SINGLE')LOOP
                  L_COVERAGE_TYPE1  := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE1     := K.DEDUCTIBLE;
                  L_ROLLOVER1       := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE NOT IN('SINGLE','EE_FAMILY'))LOOP
                  L_COVERAGE_TYPE2 := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE2    := K.DEDUCTIBLE;
                  L_ROLLOVER2      := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE = 'EE_FAMILY')LOOP
                  L_COVERAGE_TYPE3 := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE3    := K.DEDUCTIBLE;
                  L_ROLLOVER3      := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              IF L_COVERAGE_TYPE1 IS NOT NULL OR L_COVERAGE_TYPE2 IS NOT NULL OR L_COVERAGE_TYPE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('COVERAGE_TIER','; Coverage Tier (s)</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('COVERAGE_TIER','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE1 IS NOT NULL OR L_DEDUCTIBLE2 IS NOT NULL OR L_DEDUCTIBLE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLES','; Deductibles </br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLES','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER1 IS NOT NULL OR L_ROLLOVER2 IS NOT NULL OR L_ROLLOVER3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','; Rollover </br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY',L_COVERAGE_TYPE1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_1','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY',L_COVERAGE_TYPE2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_2','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY',L_COVERAGE_TYPE3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY1','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_1',L_DEDUCTIBLE1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_11','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_1',L_DEDUCTIBLE2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_11','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_22','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_1',L_DEDUCTIBLE3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_22','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY2','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_2',L_ROLLOVER1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_111','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_2',L_ROLLOVER2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_111','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_222','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_2',L_ROLLOVER3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_222','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              PC_NOTIFICATIONS.SET_TOKEN ('FUNDING','Funding',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_PERIOD','Runout Period',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PRORATE_H','Prorate New Hire Elections',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('EOB_H','EOB Required',L_NOTIFICATION_ID);
              --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCRM','Non-Discrimination Testing',L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END NOTIFY_ER_HRA_FSA_PLAN_RENEW;

  PROCEDURE ERISA_RENEWAL_NOTICE IS

         L_NOTIFICATION_ID       NUMBER;
         L_TEMPLATE_SUB_30       VARCHAR2(4000);
         L_TEMPLATE_BOD_30       VARCHAR2(4000);
         L_CC_EMAIL_30           VARCHAR2(4000);
         L_TEMPLATE_SUB_60       VARCHAR2(4000);
         L_TEMPLATE_BOD_60       VARCHAR2(4000);
         L_CC_EMAIL_60           VARCHAR2(4000);
         L_ACC_NUM               VARCHAR2(20);
         L_TO_ADDRESS            VARCHAR2(4000);
         L_CC_ADDRESS            VARCHAR2(4000);
         L_SALES_REP_EMAIL       VARCHAR2(4000);
         num_tbl number_tbl;
         e_template_not_defined    EXCEPTION;
  BEGIN
         FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                          A.TEMPLATE_BODY,
                          A.CC_ADDRESS
                     FROM NOTIFICATION_TEMPLATE A
                    WHERE A.TEMPLATE_NAME = 'ERISA_WRAP_30_DAY_RENEWAL_NOTICE'
                      AND A.STATUS = 'A') LOOP
             L_TEMPLATE_SUB_30 := J.TEMPLATE_SUBJECT;
             L_TEMPLATE_BOD_30 := J.TEMPLATE_BODY;
             L_CC_EMAIL_30     := J.CC_ADDRESS;
         END LOOP;
         IF L_TEMPLATE_SUB_30 IS NULL THEN
            raise e_template_not_defined;
         END IF;
         L_NOTIFICATION_ID := NULL;
         --30 Days Notifications
         FOR K IN (SELECT A.NAME,
                          C.PLAN_END_DATE,
                          A.ENTRP_EMAIL,
                          B.ACC_NUM,
                          B.ACC_ID,
                          A.ENTRP_CODE,
                          a.entrp_id
                     FROM ENTERPRISE A,
                          ACCOUNT B,
                          BEN_PLAN_ENROLLMENT_SETUP C
                    WHERE B.ACCOUNT_TYPE   = 'ERISA_WRAP'
                      AND B.ACCOUNT_STATUS = 1
                      AND A.ENTRP_ID       = B.ENTRP_ID
                      AND C.ACC_ID         = B.ACC_ID
                      AND C.STATUS         = 'A'
                      AND C.BEN_PLAN_ID    = (SELECT MAX(BEN_PLAN_ID)
                                                FROM BEN_PLAN_ENROLLMENT_SETUP D
                                               WHERE D.ACC_ID = B.ACC_ID
                                                 AND D.STATUS = 'A')
                      AND C.PLAN_END_DATE  = TRUNC(SYSDATE)+30) LOOP

                l_to_address :=  PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(K.ENTRP_CODE,'-'));
                L_SALES_REP_EMAIL :=  PC_CONTACT.GET_SALESREP_EMAIL(k.ENTRP_ID) ;
                 if L_SALES_REP_EMAIL IS NOT NULL THEN
                    L_CC_ADDRESS := NVL(L_CC_EMAIL_30,'compliance@sterlingadministration.com')
                                    ||','||L_SALES_REP_EMAIL;
                 END IF;
                  IF USER <> 'SAM' THEN
                    L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
                    L_CC_ADDRESS := null;
                 END IF;

                PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                               (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                               ,P_TO_ADDRESS      => L_TO_ADDRESS--K.ENTRP_EMAIL
                               ,P_CC_ADDRESS      => L_CC_ADDRESS--L_CC_EMAIL_30
                               ,P_SUBJECT         => L_TEMPLATE_SUB_30
                               ,P_MESSAGE_BODY    => L_TEMPLATE_BOD_30
                               ,P_USER_ID         => 0
                               ,P_EVENT           => 'ERISA_WRAP_30_DAY_RENEWAL_NOTICE'
                               ,P_ACC_ID          => K.ACC_ID
                               ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

                               PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',K.NAME,L_NOTIFICATION_ID);
                               PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',K.ACC_NUM,L_NOTIFICATION_ID);
                               PC_NOTIFICATIONS.SET_TOKEN ('EXPIRED_DATE',TO_CHAR(K.PLAN_END_DATE,'MM/DD/RRRR'),L_NOTIFICATION_ID);

                  num_tbl.delete;
                  FOR XX IN (select rownum rn,USER_ID
                              from online_users
                             where emp_reg_type = 2
                             and tax_id=k.entrp_code
                             and user_status <> 'D')
                  LOOP
                        num_tbl(num_tbl.count) := xx.user_id;
                  END LOOP;
                  UPDATE EMAIL_NOTIFICATIONS
                     SET MAIL_STATUS = 'READY'
                   WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
         END LOOP;

         FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                          A.TEMPLATE_BODY,
                          A.CC_ADDRESS
                     FROM NOTIFICATION_TEMPLATE A
                    WHERE A.TEMPLATE_NAME = 'ERISA_WRAP_60_DAY_RENEWAL_NOTICE'
                      AND A.STATUS = 'A') LOOP
             L_TEMPLATE_SUB_60 := J.TEMPLATE_SUBJECT;
             L_TEMPLATE_BOD_60 := J.TEMPLATE_BODY;
             L_CC_EMAIL_60     := J.CC_ADDRESS;
         END LOOP;
         IF L_TEMPLATE_SUB_60 IS NULL THEN
            raise e_template_not_defined;
         END IF;
         L_NOTIFICATION_ID := NULL;
         --60 Days Notifications
         FOR K IN (SELECT A.NAME,
                          C.PLAN_END_DATE,
                          A.ENTRP_EMAIL,
                          B.ACC_NUM,
                          B.ACC_ID ,
                          A.ENTRP_CODE,
                          A.ENTRP_ID
                     FROM ENTERPRISE A,
                          ACCOUNT B,
                          BEN_PLAN_ENROLLMENT_SETUP C
                    WHERE B.ACCOUNT_TYPE   = 'ERISA_WRAP'
                      AND B.ACCOUNT_STATUS = 1
                      AND A.ENTRP_ID       = B.ENTRP_ID
                      AND C.ACC_ID         = B.ACC_ID
                      AND C.STATUS         = 'A'
                      AND C.BEN_PLAN_ID    = (SELECT MAX(BEN_PLAN_ID)
                                                FROM BEN_PLAN_ENROLLMENT_SETUP D
                                               WHERE D.ACC_ID = B.ACC_ID
                                                 AND D.STATUS = 'A')
                      AND C.PLAN_END_DATE  = TRUNC(SYSDATE)+90) LOOP

                l_to_address :=  PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(K.ENTRP_CODE,'-'));
                L_SALES_REP_EMAIL :=  PC_CONTACT.GET_SALESREP_EMAIL(k.ENTRP_ID) ;
                 if L_SALES_REP_EMAIL IS NOT NULL THEN
                    L_CC_ADDRESS := NVL(L_CC_EMAIL_60,'compliance@sterlingadministration.com')
                                    ||','||L_SALES_REP_EMAIL;
                 END IF;
                  IF USER <> 'SAM' THEN
                    L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
                    L_CC_ADDRESS := null;
                 END IF;
             IF l_to_address IS NOT NULL OR L_CC_ADDRESS IS NOT NULL THEN
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                               (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                               ,P_TO_ADDRESS      => NVL(l_to_address,l_cc_address)--K.ENTRP_EMAIL
                               ,P_CC_ADDRESS      => l_cc_address--L_CC_EMAIL_60
                               ,P_SUBJECT         => L_TEMPLATE_SUB_60
                               ,P_MESSAGE_BODY    => L_TEMPLATE_BOD_60
                               ,P_USER_ID         => 0
                               ,P_EVENT           => 'ERISA_WRAP_60_DAY_RENEWAL_NOTICE'
                               ,P_ACC_ID          => K.ACC_ID
                               ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

                               PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',K.NAME,L_NOTIFICATION_ID);
                               PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',K.ACC_NUM,L_NOTIFICATION_ID);
                               PC_NOTIFICATIONS.SET_TOKEN ('EXPIRED_DATE',TO_CHAR(K.PLAN_END_DATE,'MM/DD/RRRR'),L_NOTIFICATION_ID);
                 num_tbl.delete;
                  FOR XX IN (select rownum rn,USER_ID
                              from online_users
                             where emp_reg_type = 2
                             and tax_id=k.entrp_code
                             and user_status <> 'D')
                  LOOP
                        num_tbl(num_tbl.count) := xx.user_id;
                  END LOOP;
                  add_notify_users(num_tbl,l_notifICATION_id);
                  UPDATE EMAIL_NOTIFICATIONS
                     SET MAIL_STATUS = 'READY'
                   WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
           END IF;
         END LOOP;
  EXCEPTION
     WHEN e_template_not_defined THEN
          INSERT_ALERT('TEMPLATE NOT DEFINED','ERISA 30/60 day notice is not defined');

  END ERISA_RENEWAL_NOTICE;

  PROCEDURE COBRA_RENEWAL_NOTICE IS

         L_NOTIFICATION_ID       NUMBER;
         L_TEMPLATE_SUB_30       VARCHAR2(4000);
         L_TEMPLATE_BOD_30       VARCHAR2(4000);
         L_CC_EMAIL_30           VARCHAR2(4000);
         L_TEMPLATE_SUB_60       VARCHAR2(4000);
         L_TEMPLATE_BOD_60       VARCHAR2(4000);
         L_CC_EMAIL_60           VARCHAR2(4000);
         L_EMAIL                 VARCHAR2(4000);
         L_ACC_NUM               VARCHAR2(20);
         num_tbl number_tbl;
         L_TO_ADDRESS         VARCHAR2(4000);
         L_CC_ADDRESS         VARCHAR2(4000);
         L_SALES_REP_EMAIL    VARCHAR2(4000);
                  e_template_not_defined    EXCEPTION;

  BEGIN
         FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                          A.TEMPLATE_BODY,
                          A.CC_ADDRESS
                     FROM NOTIFICATION_TEMPLATE A
                    WHERE A.TEMPLATE_NAME = 'COBRA_30_DAY_RENEWAL_NOTICE'
                      AND A.STATUS = 'A') LOOP
             L_TEMPLATE_SUB_30 := J.TEMPLATE_SUBJECT;
             L_TEMPLATE_BOD_30 := J.TEMPLATE_BODY;
             if J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
         END LOOP;
         IF L_TEMPLATE_SUB_30 IS NULL THEN
            raise e_template_not_defined;
         END IF;
         --30 Days Notifications
         FOR K IN (SELECT A.NAME,
                          A.ENTRP_EMAIL,
                          ADD_MONTHS(B.START_DATE,12)-1 PLAN_END_DATE,
                          B.ACC_NUM,
                          B.ACC_ID ,
                          A.ENTRP_CODE,
                          A.ENTRP_ID
                     FROM ENTERPRISE A,
                          ACCOUNT B,
                          (select acc_id,max(start_date)start_date,max(end_date)end_date
                          from ben_plan_renewals where plan_type='COBRA'group by acc_id)c
                    WHERE B.ACCOUNT_TYPE   = 'COBRA'
                      AND B.ACCOUNT_STATUS = 1
                      AND A.ENTRP_ID       = B.ENTRP_ID and b.acc_id=c.acc_id(+)--and b.acc_id=248270
                      AND TRUNC(SYSDATE)   = ADD_MONTHS(B.START_DATE,11)-1) LOOP


            L_TO_ADDRESS :=  PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(k.ENTRP_CODE,'-'));
            L_CC_ADDRESS := 'cobra@sterlingadministration.com,IT-Team@sterlingadministration.com';

            L_SALES_REP_EMAIL := PC_CONTACT.GET_SALESREP_EMAIL(K.ENTRP_ID) ;
             if L_SALES_REP_EMAIL IS NOT NULL THEN
                L_CC_ADDRESS := L_CC_ADDRESS||','||L_SALES_REP_EMAIL;
             END IF;
            IF USER <> 'SAM' THEN
              L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
              L_CC_ADDRESS := null;
            END IF;
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                               (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                               ,P_TO_ADDRESS      => L_TO_ADDRESS--K.ENTRP_EMAIL
                               ,P_CC_ADDRESS      => L_CC_ADDRESS--L_CC_EMAIL_30
                               ,P_SUBJECT         => L_TEMPLATE_SUB_30
                               ,P_MESSAGE_BODY    => L_TEMPLATE_BOD_30
                               ,P_USER_ID         => 0
                               ,P_EVENT           => 'COBRA_30_DAY_RENEWAL_NOTICE'
                               ,P_ACC_ID          => K.ACC_ID
                               ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

                    PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',K.NAME,L_NOTIFICATION_ID);
                    PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',K.ACC_NUM,L_NOTIFICATION_ID);
                    PC_NOTIFICATIONS.SET_TOKEN ('EXPIRED_DATE',TO_CHAR(K.PLAN_END_DATE,'MM/DD/RRRR'),L_NOTIFICATION_ID);
                   num_tbl.delete;

                  FOR XX IN (select rownum rn,USER_ID
                              from online_users
                             where emp_reg_type = 2
                             and tax_id=k.entrp_code
                             and user_status <> 'D')
                  LOOP
                        num_tbl(num_tbl.count) := xx.user_id;
                  END LOOP;
                  add_notify_users(num_tbl,l_notifICATION_id);



                   UPDATE EMAIL_NOTIFICATIONS
                     SET MAIL_STATUS = 'READY'
                   WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
         END LOOP;

         L_NOTIFICATION_ID := NULL;

         FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                          A.TEMPLATE_BODY,
                          A.CC_ADDRESS
                     FROM NOTIFICATION_TEMPLATE A
                    WHERE A.TEMPLATE_NAME = 'COBRA_60_DAY_RENEWAL_NOTICE'
                      AND A.STATUS = 'A') LOOP
             L_TEMPLATE_SUB_60 := J.TEMPLATE_SUBJECT;
             L_TEMPLATE_BOD_60 := J.TEMPLATE_BODY;
             if J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
         END LOOP;
         IF L_TEMPLATE_SUB_60 IS NULL THEN
            raise e_template_not_defined;
         END IF;
         --60 Days Notifications
         FOR K IN (SELECT A.NAME,
                          A.ENTRP_EMAIL,
                          ADD_MONTHS(nvl(c.start_date,B.START_DATE),12)-1 PLAN_END_DATE,
                          B.ACC_NUM,
                          B.ACC_ID ,
                          A.ENTRP_CODE,
                          A.ENTRP_ID
                     FROM ENTERPRISE A,
                          ACCOUNT B,
                          (select acc_id,max(start_date)start_date,max(end_date)end_date
                          from ben_plan_renewals where plan_type='COBRA'group by acc_id)c
                    WHERE B.ACCOUNT_TYPE   = 'COBRA'
                      AND B.ACCOUNT_STATUS = 1
                      AND A.ENTRP_ID       = B.ENTRP_ID
                      and b.acc_id=c.acc_id(+)--and b.acc_id=248270
                      AND TRUNC(SYSDATE)   = ADD_MONTHS(B.START_DATE,12)-90) LOOP

            L_TO_ADDRESS :=  PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(k.ENTRP_CODE,'-'));
            L_CC_ADDRESS := 'cobra@sterlingadministration.com,IT-Team@sterlingadministration.com';

            L_SALES_REP_EMAIL := PC_CONTACT.GET_SALESREP_EMAIL(k.ENTRP_ID) ;
             if L_SALES_REP_EMAIL IS NOT NULL THEN
                L_CC_ADDRESS := L_CC_ADDRESS||','||L_SALES_REP_EMAIL;
             END IF;
            IF USER <> 'SAM' THEN
              L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
              L_CC_ADDRESS := null;
            END IF;
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                               (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                               ,P_TO_ADDRESS      => L_TO_ADDRESS--K.ENTRP_EMAIL
                               ,P_CC_ADDRESS      => L_CC_ADDRESS--L_CC_EMAIL_60
                               ,P_SUBJECT         => L_TEMPLATE_SUB_60
                               ,P_MESSAGE_BODY    => L_TEMPLATE_BOD_60
                               ,P_USER_ID         => 0
                               ,P_EVENT           => 'COBRA_60_DAY_RENEWAL_NOTICE'
                               ,P_ACC_ID          => K.ACC_ID
                               ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

                               PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',K.NAME,L_NOTIFICATION_ID);
                               PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',K.ACC_NUM,L_NOTIFICATION_ID);
                               PC_NOTIFICATIONS.SET_TOKEN ('EXPIRED_DATE',TO_CHAR(K.PLAN_END_DATE,'MM/DD/RRRR'),L_NOTIFICATION_ID);
                  num_tbl.delete;

                  FOR XX IN (select rownum rn,USER_ID
                              from online_users
                             where emp_reg_type = 2
                             and tax_id=k.entrp_code
                             and user_status <> 'D')
                  LOOP
                        num_tbl(num_tbl.count) := xx.user_id;
                  END LOOP;
                  add_notify_users(num_tbl,l_notifICATION_id);
                   UPDATE EMAIL_NOTIFICATIONS
                     SET MAIL_STATUS = 'READY'
                   WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
         END LOOP;
   EXCEPTION
     WHEN e_template_not_defined THEN
          INSERT_ALERT('TEMPLATE NOT DEFINED','COBRA 30/60 day notice is not defined');

  END COBRA_RENEWAL_NOTICE;

  PROCEDURE NOTIFY_PLAN_DOCUMENT_UPLOAD(
         p_file_name   IN VARCHAR2
       , p_user_id     IN NUMBER
       , p_entity_name IN VARCHAR2
       , p_entity_id   IN VARCHAR2)
  IS
         l_notif_id number;
         num_tbl number_tbl;
         l_acc_id number;
         l_acc_num varchar2(100);
         l_account_type varchar2(100);
         l_ENTRP_code varchar2(100);
         pdf_count number;
         L_EMAIL                 VARCHAR2(4000);

  BEGIN
           FOR X IN (
              SELECT A.ACC_ID,A.ACC_NUM
                      ,decode(A.account_type,'ERISA_WRAP','ERISA Wrap',A.account_type) account_type
                      ,C.ENTRP_code
                FROM ACCOUNT A,BEN_PLAN_ENROLLMENT_SETUP B,enterprise c
                  WHERE A.ACC_ID=B.ACC_ID
                  AND   A.ENTRP_ID = C.ENTRP_ID
                AND BEN_PLAN_ID=P_ENTITY_ID)
           LOOP
                L_ACC_ID := X.ACC_ID;
                L_ACC_NUM := X.ACC_NUM;
                l_account_type := X.account_type;
                l_ENTRP_code := X.ENTRP_CODE;

           END LOOP;



            FOR KK IN ( SELECT email FROM
                          TABLE(PC_CONTACT.GET_NOTIFY_EMAILS(L_ENTRP_CODE,'COMPLIANCE','ERISA_WRAP',NULL)))
            LOOP
                    L_EMAIL := kk.email;
            END LOOP;
            IF L_EMAIL IS NOT NULL THEN
               FOR X IN(SELECT template_subject,template_body,to_address,cc_address
                         FROM NOTIFICATION_TEMPLATE
                         WHERE NOTIFICATION_TYPE = 'EXTERNAL'
                          AND TEMPLATE_NAME  = 'EMPLOYER_PLAN_DOCUMENTS_READY'
                        AND STATUS = 'A')
                LOOP


                  pc_notifications.insert_notifications
                  (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                  ,P_TO_ADDRESS      => L_EMAIL
                  ,P_CC_ADDRESS      => 'customer.service@sterlingadministration.com'
                  ,P_SUBJECT         => replace(x.template_subject,'<<ACCOUNT>>',l_account_type)--||' ('||to_char(pdf_count)||') ')--||' '||l_acc_num)
                  ,P_MESSAGE_BODY    => x.template_body
                  ,P_USER_ID         => p_user_id
                  ,p_event           => 'EMPLOYER_PLAN_DOCUMENTS_READY'
                  ,X_NOTIFICATION_ID => l_notif_id );

               num_tbl(1) := p_user_id;
               add_notify_users(num_tbl,l_notif_id);

               PC_NOTIFICATIONS.SET_TOKEN('ACCOUNT',L_ACC_NUM, l_notif_id);

               UPDATE EMAIL_NOTIFICATIONS
               SET    MAIL_STATUS = 'READY'
               ,    acc_id = L_acc_id
               WHERE  NOTIFICATION_ID  = l_notif_id;
             END LOOP;
        END IF;
   exception
     WHEN OTHERS THEN
        pc_log.log_error('NOTIFY_PLAN_DOCUMENT_UPLOAD ','Error message'||SQLERRM);

   END NOTIFY_PLAN_DOCUMENT_UPLOAD;


  PROCEDURE NOTIFY_ER_GENERATE_INVOICE(p_invoice_id IN NUMBER)
  IS
         l_notif_id number;
          num_tbl number_tbl;
         l_acc_id number;
         L_TO_ADDRESS VARCHAR2(4000);
         L_USER_ID    VARCHAR2(4000);
         L_ACCOUNT_TYPE VARCHAR2(30);
         L_ACC_NUM      VARCHAR2(30);
   BEGIN
   FOR X IN(SELECT template_subject,template_body,to_address,cc_address
            FROM NOTIFICATION_TEMPLATE
            WHERE NOTIFICATION_TYPE = 'EXTERNAL'
            AND TEMPLATE_NAME  = 'EMPLOYER_INVOICE_READY'
            AND STATUS = 'A')
    LOOP

               FOR XX IN (SELECT  ---WM_CONCAT(C.EMAIL) EMAIL   --- Commented by RPRABU 0n 17/10/2017
                                 LISTAGG(C.EMAIL, ',') WITHIN GROUP (ORDER BY email)  EMAIL  -- Added by RPRABU 0n 17/10/2017
                                 ---WM_CONCAT(C.user_id) user_id --- Commented by RPRABU 0n 17/10/2017
                              ,  LISTAGG(C.user_id, ',') WITHIN GROUP (ORDER BY C.user_id) user_id  -- Added by RPRABU 0n 17/10/2017
                              ,  AC.ACCOUNT_TYPE
                              ,  AC.ACC_NUM
                              ,  AC.ACC_ID
                         FROM   AR_INVOICE AR, ENTERPRISE B,
                                ONLINE_USERS C, ACCOUNT AC
                         WHERE   AR.INVOICE_ID = p_invoice_id
                         AND    AR.ENTITY_ID = B.ENTRP_ID
                         AND    C.TAX_ID = REPLACE(B.ENTRP_CODE,'-')
                         AND    C.emp_reg_type = 2
                         AND    AC.ENTRP_ID = B.ENTRP_ID
                         and    user_status <> 'D'
                         GROUP BY AC.ACCOUNT_TYPE,AC.ACC_NUM)
             LOOP
                L_TO_ADDRESS := XX.EMAIL;
                L_USER_ID    := xX.user_id;
                L_ACCOUNT_TYPE  := XX.ACCOUNT_TYPE;
                L_ACC_NUM    := XX.ACC_NUM;
                L_ACC_ID     := XX.ACC_ID;
             END LOOP;
             pc_notifications.insert_notifications
              (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
              ,P_TO_ADDRESS      => L_TO_ADDRESS--xx.email
              ,P_CC_ADDRESS      => X.cc_address--x.cc_address
              ,P_SUBJECT         => replace(x.template_subject,'<<ACCOUNT_TYPE>>'
                                 ,PC_LOOKUPS.GET_ACCOUNT_TYPE(L_ACCOUNT_TYPE))--||' '||l_acc_num)
              ,P_MESSAGE_BODY    => x.template_body
              ,P_USER_ID         => 0
              ,p_event          =>'EMPLOYER_INVOICE_READY'
              ,p_acc_id          => L_ACC_ID
              ,X_NOTIFICATION_ID => l_notif_id );

              FOR XX IN ( SELECT * FROM TABLE(IN_LIST(L_USER_ID)))
              LOOP
                        num_tbl(num_tbl.count) := TO_NUMBER(XX.COLUMN_VALUE);
              END LOOP;

               add_notify_users(num_tbl,l_notif_id);
               PC_NOTIFICATIONS.SET_TOKEN('ACCOUNT',L_ACC_NUM, l_notif_id);
                UPDATE EMAIL_NOTIFICATIONS
                SET    MAIL_STATUS = 'READY'
                WHERE  NOTIFICATION_ID  = l_notif_id;


    END LOOP;

   exception

      when others then
                 pc_log.log_error('NOTIFY_ER_GENERATE_INVOICE ','Error message'||SQLERRM);

  END NOTIFY_ER_GENERATE_INVOICE;

  PROCEDURE NOTIFY_COBRA_RECEIPTS(p_acc_id number)
  IS
      l_notif_id number;
      L_USER_ID NUMBER;
      l_acc_id number;
      num_tbl number_tbl;
      l_note varchar2(4000);
  BEGIN
       FOR X IN(SELECT template_subject,template_body,to_address,cc_address
         FROM NOTIFICATION_TEMPLATE
        WHERE NOTIFICATION_TYPE = 'EXTERNAL'
          AND TEMPLATE_NAME  = 'QUALIFIED_BENEFICIARY_PAYMENT_RECEIVED'
          AND STATUS = 'A')
        LOOP

           FOR XX IN(select a.pers_id,email,acc_num,b.acc_id,
                            fee_date,amount,replace(ssn,'-') ssn,c.note
                    from person a,account b,income c
                    where a.pers_id=b.pers_id
                    and b.acc_id=c.acc_id
                    and account_type='COBRA'
                    and b.acc_id=p_acc_id
                    and trunc(fee_date)=trunc(sysdate))
            LOOP
              l_acc_id:=xx.acc_id;
              pc_notifications.insert_notifications
              (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
              ,P_TO_ADDRESS      => xx.email
              ,P_CC_ADDRESS      => x.cc_address
              ,P_SUBJECT         => x.template_subject--replace(x.template_subject,'<<ACCOUNT>>',l_account_type)--||' '||l_acc_num)
          --    ,P_SUBJECT         => x.template_subject--replace(x.template_subject,'<>',xx.acc_num)
              ,P_MESSAGE_BODY    => x.template_body
              ,P_USER_ID         => L_user_id,p_event=>'QUALIFIED_BENEFICIARY_PAYMENT_RECEIVED'
              ,p_acc_id=>xx.acc_id
              ,X_NOTIFICATION_ID => l_notif_id );

               add_notify_users(num_tbl,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN('ACCOUNT_NUMBER',xx.ACC_NUM, l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN('NOTE',xx.note, l_notif_id);

        END LOOP;
          UPDATE EMAIL_NOTIFICATIONS
          SET    MAIL_STATUS = 'READY'
            ,    acc_id = L_acc_id
          WHERE  NOTIFICATION_ID  = l_notif_id;

    END LOOP;
  END NOTIFY_COBRA_RECEIPTS;


  PROCEDURE notify_pending_approvals
IS
  l_template_sub VARCHAR2(1000);
  l_template_bod VARCHAR2(3000);
  l_cc_address   VARCHAR2(100);
  l_user_id      NUMBER;
  num_tbl number_tbl;
  L_NOTIFICATION_ID NUMBER;
  l_to_Address      VARCHAR2(1000);
BEGIN
  FOR J IN
  (SELECT A.TEMPLATE_SUBJECT,
    A.TEMPLATE_BODY,
    CC_ADDRESS
  FROM NOTIFICATION_TEMPLATE A
  WHERE A.TEMPLATE_NAME = 'NOTIFY_PENDING_APPROVALS'
  AND A.STATUS          = 'A'
  )
  LOOP
    L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
    L_TEMPLATE_BOD := J.TEMPLATE_BODY;
    l_cc_address   := J.CC_ADDRESS;
  END LOOP;
  --Extract the list of Employers
  FOR X IN
  ( SELECT DISTINCT entrp_id,pc_entrp.get_entrp_name(entrp_id)Employer_Name
  FROM
    (SELECT
      (SELECT acc_num FROM ACCOUNT WHERE entrp_id =d.entrp_id
      ) acc_num ,
      d.entrp_id,
      COUNT(*)
    FROM BEN_PLAN_ENROLLMENT_SETUP a,
      ACCOUNT c,
      PERSON d
    WHERE a.STATUS      = 'P'
    AND a.acc_id        = c.acc_id
    AND c.pers_id       = d.pers_id
    AND a.PRODUCT_TYPE IN('HRA','FSA')
      GROUP BY d.entrp_id
    HAVING COUNT(*) >= 1
    UNION
    SELECT b.acc_num ,
      b.entrp_id,
      COUNT(*)
    FROM BEN_LIFE_EVENT_HISTORY a ,
      ACCOUNT b
    WHERE a.entrp_id       = b.entrp_id
    and b.account_status=1
    AND b.account_type    IN ('FSA','HRA')
    AND (processed_status <> 'Y'
    OR processed_status   IS NULL)
    AND status             = 'P'
     GROUP BY b.acc_num,
      b.entrp_id
    HAVING COUNT(*) >= 1
    )
  )
  LOOP
    FOR Y IN
    (SELECT distinct email
    FROM online_users a,
      enterprise b
    WHERE b.entrp_id = X.entrp_id
    AND a.tax_id     = b.entrp_code --find_key   = X.acc_num
    AND emp_reg_type = 2
    AND user_status  ='A'
    )    --Super Admin
    LOOP --Super admin loop
      PC_NOTIFICATIONS.INSERT_NOTIFICATIONS (
       P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
       ,P_TO_ADDRESS => Y.email
       ,P_CC_ADDRESS => l_cc_address
       ,P_SUBJECT => REPLACE(L_TEMPLATE_SUB,'<<EMPLOYER_NAME>>',pc_entrp.get_entrp_name(X.entrp_id))
       ,P_MESSAGE_BODY => L_TEMPLATE_BOD
       ,P_USER_ID =>0
       ,P_EVENT => 'NOTIFY_PENDING_APPROVALS'
       ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

       FOR XX IN (SELECT user_id from online_users where email = y.email and emp_reg_type = 2
                  AND user_status  ='A')
       LOOP
          num_tbl(1) := xx.user_id;
          add_notify_users(num_tbl,L_NOTIFICATION_ID);
       END LOOP;
       UPDATE EMAIL_NOTIFICATIONS
      SET MAIL_STATUS       = 'READY'
      WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
    END LOOP; --End of Super Admin loop
  END LOOP;   --End of Employer Loop
END notify_pending_approvals;

PROCEDURE Notify_acct_termination
 IS
    l_message_body VARCHAR2(4000);
     l_notif_id     NUMBER;
     l_acc_id      NUMBER;num_tbl number_tbl;
     l_person_name  VARCHAR2(1000);
     l_email   VARCHAR2(1000);
     l_user_id NUMBER;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
              AND    TEMPLATE_NAME ='HSA_ACCOUNT_TERMINATION'
              AND    STATUS = 'A')
   LOOP --Template Loop
       FOR Y IN (select a.acc_num,a.acc_id,b.first_name,b.last_name,b.SSN,b.email
                 from ACCOUNT a,PERSON b
                 WHERE closed_reason is NOT NULL
                 and trunc(end_date) = trunc(SYSDATE)
                 and a.pers_id = b.pers_id
                 and account_status = 4
                 and a.account_type = 'HSA'
               --  and a.acc_num in ('ICA017042','ICA002458')
                -- and rownum < 3
                 )
       LOOP --Terminated Accounts loop

    BEGIN
           SELECT user_id,email
           INTO l_user_id,l_email
           from online_users
           where replace(tax_id,'-') = replace(Y.SSN,'-')
           and find_key = Y.acc_num
           and user_status = 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_email := Y.email;
              l_user_id := NULL;
            WHEN OTHERS THEN
              l_email := Y.email;
              l_user_id := NULL;
          END;

          IF l_email IS NOT NULL THEN
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
           (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
          ,P_TO_ADDRESS   => l_email
          ,P_CC_ADDRESS => X.cc_address
          ,P_SUBJECT      => x.template_subject
          ,P_MESSAGE_BODY => x.template_body
          ,P_USER_ID      => l_user_id
          ,P_ACC_ID       => y.acc_id
          ,X_NOTIFICATION_ID => l_notif_id );

          num_tbl(1):=l_user_id;
       add_notify_users(num_tbl,l_notif_id);
       l_person_name := Y.first_name||' '||Y.last_name;

       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',l_person_name,l_notif_id);

        UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;
        pc_log.log_error('NOTIFICATION.Hsa_account_termination','l_notif_id '||l_notif_id );

        END IF;--Email Loop
       END LOOP; -- Acct loop
    END LOOP;--Template Loop
    exception
       WHEN OTHERS THEN
         Pc_log.log_error('PC_NOTIFICATION.Hsa_acct_termination',SQLERRM);
  END Notify_acct_termination;
  PROCEDURE INSERT_REPORTS
          (P_REPORT_NAME IN VARCHAR2
         , P_REPORT_DIR  IN VARCHAR2
         , P_FILE_NAME   IN VARCHAR2
         , P_FILE_ACTION IN VARCHAR2
          , P_REPORT_DESCRIPTION IN VARCHAR2)
  IS
  BEGIN
     INSERT INTO REPORTS
     (REPORT_ID,REPORT_NAME,REPORT_DIR,FILE_NAME,REPORT_ACTION,REPORT_DESCRIPTION)
     VALUES
     (REPORTS_SEQ.NEXTVAL,P_REPORT_NAME,P_REPORT_DIR,P_FILE_NAME,P_FILE_ACTION,P_REPORT_DESCRIPTION);
  END INSERT_REPORTS;

   PROCEDURE notify_er_hsa_verified(p_acc_id varchar2)
   is
       l_notif_id     NUMBER;
       num_tbl number_tbl;
       l_user_id NUMBER;
       l_type varchar2(40):=pc_account.get_account_type(p_acc_id);
   begin
      FOR X IN ( SELECT a.template_subject
                   ,  a.template_body
                   ,  a.to_address
                   ,  a.cc_address
               FROM   NOTIFICATION_TEMPLATE A
               WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
               AND    TEMPLATE_NAME =decode(l_type,'HSA','ER_HSA_VERIFIED','ER_HRA_VERIFIED')
               AND    STATUS = 'A')
    LOOP --Template Loop
        FOR Y IN (select a.acc_num,name,entrp_email,entrp_code
                  from ACCOUNT a,enterprise b
                  WHERE a.entrp_id=b.entrp_id
                   and acc_id=p_acc_id)
        loop
             select USER_ID into l_user_id
               from online_users
            where emp_reg_type = 2
              and tax_id=y.entrp_code
               and user_status <> 'D'and rownum=1;--dbms_output.put_line(pc_lookups.get_account_type(l_type));

           IF y.entrp_email IS NOT NULL THEN
               PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
               ,P_TO_ADDRESS   => y.entrp_email
               ,P_CC_ADDRESS => X.cc_address
               ,P_SUBJECT      => replace(x.template_subject,'<TYPE>',pc_lookups.get_account_type(l_type))
               ,P_MESSAGE_BODY => x.template_body
               ,P_USER_ID      => l_user_id
               ,P_ACC_ID       => p_acc_id
               ,X_NOTIFICATION_ID => l_notif_id);

               num_tbl(1):=l_user_id;
              add_notify_users(num_tbl,l_notif_id);

              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',y.acc_num,l_notif_id);
              PC_NOTIFICATIONS.SET_TOKEN ('TYPE',pc_lookups.get_account_type(l_type),l_notif_id);

               UPDATE EMAIL_NOTIFICATIONS
                  SET    MAIL_STATUS = 'READY'
               WHERE  NOTIFICATION_ID  = l_notif_id;
               pc_log.log_error('NOTIFICATION.er_Hsa_verified','l_notif_id '||l_notif_id );

            END IF;--Email Loop


       end loop;
     end loop;
   exception
     when others then
         dbms_output.put_line(sqlerrm);
   end;


 PROCEDURE claim_invoice_refund_notify
 (p_invoice_id IN NUMBER
 ,p_claim_ids  IN VARCHAR2
 ,p_acc_id     IN NUMBER
 ,p_entrp_id   IN NUMBER)
  IS
     l_message_body VARCHAR2(4000);
     l_notif_id     NUMBER;
     l_acc_id      NUMBER;
     l_cc_address   VARCHAR2(255);
     l_template_subject VARCHAR2(4000);
     l_template_body  VARCHAR2(32000);
     l_content        VARCHAR2(32000);
     num_tbl          number_tbl;
     l_claim_ids      NUMBER;
  BEGIN
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
          AND    TEMPLATE_NAME = 'CLAIM_INVOICE_REFUND_UNDERPAY'
              AND    STATUS = 'A')
   LOOP

      l_cc_address := x.cc_address;
      l_template_body := x.template_body;
      l_template_subject := x.template_subject;

   END LOOP;
   FOR X IN (select  --- wm_concat(email) emails   --- Commented by RPRABU 0n 17/10/2017
             LISTAGG(email, ',') WITHIN GROUP (ORDER BY email)  emails  -- Added by RPRABU 0n 17/10/2017
       from online_users
       where user_status = 'A' and emp_reg_type <> 1 and replace(tax_id,'-') =
       (select entrp_code from enterprise where entrp_id = p_entrp_id))
   LOOP

      PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
       (P_FROM_ADDRESS => 'benefits@sterlingadministration.com'
       ,P_TO_ADDRESS   => x.emails
       ,P_CC_ADDRESS   => 'benefits@sterlingadministration.com'
       ,P_SUBJECT      => REPLACE(l_template_subject,'<<INVOICE_ID>>',p_invoice_id)
       ,P_MESSAGE_BODY => l_template_body
       ,P_USER_ID      => 0
       ,P_ACC_ID       => p_acc_id
       ,X_NOTIFICATION_ID => l_notif_id );

        PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_NUMBERS',p_claim_ids,l_notif_id);
    END LOOP;
    BEGIN
       select  USER_ID BULK COLLECT INTO num_tbl
       from online_users
       where  user_status = 'A' and emp_reg_type <> 1 and replace(tax_id,'-') =
       (select entrp_code from enterprise where entrp_id = p_entrp_id);
    EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;
    IF num_tbl.COUNT > 0 THEN
          add_notify_users(num_tbl,l_notif_id);
    END IF;
         UPDATE EMAIL_NOTIFICATIONS
           SET    MAIL_STATUS = 'READY'
        WHERE  NOTIFICATION_ID  = l_notif_id;

     exception
        WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
  END claim_invoice_refund_notify;
  PROCEDURE email_partially_paid_claim_inv(p_invoice_id IN NUMBER)
  AS
     l_html_message   VARCHAR2(32000);
     l_sql            VARCHAR2(32000);

  BEGIN

    l_html_message  := '<html>
      <head>
          <title>Partially Paid Invoice</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Partially Paid Invoice </p>
       </table>
        </body>
        </html>';
    l_sql := 'SELECT invoice_id, invoice_amount-nvl(void_amount,0) invoice_amount
                     , paid_amount, pending_amount
                FROM AR_INVOICE WHERE invoice_id = '||p_invoice_id;



     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,g_hrafsa_email
                           ,'partial_paid_invoice_'||p_invoice_id||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Partially Paid Invoice for '||p_invoice_id);
 EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line('error message '||SQLERRM);
  end email_partially_paid_claim_inv;
PROCEDURE daily_online_er_regn IS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

    V_EMAIL                VARCHAR2(4000):='IT-team@sterlingadministration.com'||case USER when'SAM'THEN
   ',accountmanagement@sterlingadministration.com,Janna.Smith@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'
   ||'sarah.soman@sterlingadministration.com,salesdirectors@sterlingadministration.com'end;
 BEGIN
     l_html_message  := '<html>
      <head>
          <title>Daily Online Employer Enrollment Report</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Daily Online Employer Enrollment Report</p>
       </table>
        </body>
        </html>';



    l_sql :=
       'SELECT B.ACC_NUM "Account Number"
             ,A.NAME "Employer Name"
             ,A.ENTRP_CODE "Tax ID"
             ,A.ADDRESS "Address"
             ,A.CITY "City"
             ,A.STATE "State"
             ,A.ZIP "Zip"
             ,entrp_phones "Phone Number"
             ,B.account_type "Account Type"
             ,C.Salesrep_FLAG "Working With Salesrep"
             ,C.Salesrep_Name "Sales Rep"

       FROM ENTERPRISE A,ACCOUNT B ,EMPLOYER_ONLINE_ENROLLMENT C

        WHERE A.entrp_id = b.entrp_id
        and REPLACE(A.ENTRP_CODE,''-'')=REPLACE(C.EIN_NUMBER,''-'')
          AND account_status = 3
          AND complete_flag <> 1
          AND B.enrollment_source=''ONLINE''
          AND B.Decline_Date is Null
         AND TRUNC(a.creation_date) >= trunc(SYSDATE-1)';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,v_email
                           ,'online_er_enroll_'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           ,  'Daily Incomplete Online Employer Enrollment Report for '||to_char(sysdate,'MM/DD/YYYY'));

 EXCEPTION
     WHEN others then
      dbms_output.enable;
      dbms_output.put_line(sqlerrm);
END daily_online_er_regn;

PROCEDURE daily_completed_employer IS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

   V_EMAIL                VARCHAR2(4000):='IT-team@sterlingadministration.com'||case USER when'SAM'THEN
   ',accountrepresentatives@sterlingadministration.com,salesdirectors@sterlingadministration.com,accountrepresentative@sterlingadministration.com,Yvonne.Eisenman@sterlingadministration.com,'
   ||'dana.ramos@sterlingadministration.com,sarah.soman@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'end;
 BEGIN
     l_html_message  := '<html>
      <head>
          <title>Daily Completed Employer Report</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Daily Completed Employer Report</p>
       </table>
        </body>
        </html>';

    /*Ticket#6834 .Will disply Enrolled by and name */
     l_sql := 'SELECT acc_num "Account Number"
                  ,   name  "Employer Name"
                     ,   account_type "Account Type"
                     ,   salesrep "Salesrep Name"
                     ,enrolled_by "Enrolled By "
                     ,broker_employer_name "Name"
              FROM ( SELECT ACC_NUM,
                        account_type,
                        acc_id,
                        pc_entrp.get_entrp_name(entrp_id) name,
                         pc_sales_team.GET_SALES_REP_NAME(salesrep_id) salesrep
                           ,CASE WHEN (SELECT count(*) from ONLINE_USERS ou ,BEN_PLAN_ENROLLMENT_SETUP bp where bp.created_by = ou.user_id and a.acc_id = bp.acc_id and user_type = ''B'' ) >= 1 THEN ''Broker''
                          ELSE ''Employer''
                          END enrolled_by
                            ,CASE WHEN (SELECT count(*) from ONLINE_USERS ou ,BEN_PLAN_ENROLLMENT_SETUP bp where bp.created_by = ou.user_id and a.acc_id = bp.acc_id and bp.created_by = ou.user_id and user_type = ''B'') >= 1  THEN ( SELECT first_name||last_name from person p,broker b ,online_users ou,ben_plan_enrollment_setup bp where a.acc_id = bp.acc_id and  ou.user_id = bp.created_by and ou.tax_id = b.broker_lic and p.pers_id = b.broker_id)
                           ELSE (SELECT user_name from online_users where user_id = a.created_by)
                          END Broker_employer_name
                    FROM ACCOUNT a
                    WHERE A.complete_flag =1
                     AND A.account_status=3
                     AND A.ENTRP_ID IS NOT NULL
                      AND A.enrollment_source = ''ONLINE''
                       AND EXISTS
                           (SELECT 1
                        FROM BEN_PLAN_ENROLLMENT_SETUP bp
                             WHERE bp.acc_id=a.acc_id
                         AND bp.ben_plan_id_main IS NULL
                         AND TRUNC(bp.creation_date) >=trunc(sysdate-1 ))
                           union
                          SELECT a.ACC_NUM,
                          a.account_type,
                          a.acc_id,
                          pc_entrp.get_entrp_name(a.entrp_id),
                           pc_sales_team.GET_SALES_REP_NAME(a.salesrep_id) salesrep
                        ,CASE WHEN (SELECT count(*) from ONLINE_USERS ou where a.created_by = ou.user_id and user_type = ''B'' ) >= 1 THEN ''Broker''
                          ELSE ''Employer''
                          END enrolled_by
                            ,CASE WHEN (SELECT count(*) from ONLINE_USERS ou where a.created_by = ou.user_id and user_type = ''B'') >= 1  THEN ( SELECT first_name||last_name from person p,broker b,online_users ou where ou.user_id = a.created_by and ou.tax_id = b.broker_lic and p.pers_id = b.broker_id)
                           ELSE (SELECT user_name from online_users where user_id = a.created_by)
                          END Broker_employer_name
                      FROM ACCOUNT a,PLANS b
                           WHERE a.plan_code=b.plan_code
                       AND complete_flag =1
                       AND account_status=3
                       AND A.ENTRP_ID IS NOT NULL
                       AND enrollment_source = ''ONLINE''
                       AND a.account_type=''HSA''
                       AND TRUNC(a.creation_date) >=trunc(sysdate -1)) WHERE 1 = 1';


                   mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,v_email
                           ,'daily_completed_er_'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           ,  'Daily Completed Employer Report for '||to_char(sysdate,'MM/DD/YYYY'));

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.enable;
      dbms_output.put_line(sqlerrm);--||dbms_utility.format_error_backtrace);
END daily_completed_employer;
PROCEDURE daily_new_er_invoice IS
   V_WORK_SHEET           VARCHAR2(4000);
   V_FILE_NAME_g          VARCHAR2(4000):='Daily_#_New_ER_Invoice_'--||PC_FILE_UPLOAD.INSERT_FILE_SEQ('DAILY_NEW_ER_INVOICE')
   ||TO_CHAR(SYSDATE,'YYYYMMDD')||'.xls';
   V_FILE_NAME            VARCHAR2(4000);
   r number;c number;n number;snd_inv varchar2(4000);
   V_HTML_MSG             VARCHAR2(4000):= '<html><body><br><p>Daily # New ER Invoice Report for the Date '||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'</p><br><br></body></html>';
   V_EMAIL                VARCHAR2(4000):= 'IT-team@sterlingadministration.com,VHSTeam@sterlingadministration.com';
   l_col_tbl              GEN_XL_XML.VARCHAR2_TBL;
   l_col_value_tbl              GEN_XL_XML.VARCHAR2_TBL;

   PROCEDURE list_price(row number,c number,quote number,coverage varchar2)is
   begin
       SELECT count(*)
         into n
         FROM rate_plan_detail a,ar_quote_lines b
        WHERE a.rate_plan_detail_id=b.rate_plan_detail_id
          AND coverage_type    =coverage
          AND quote_header_id=quote;

       if n > 0then
         SELECT line_list_price
           into n
           FROM rate_plan_detail a,ar_quote_lines b
          WHERE a.rate_plan_detail_id=b.rate_plan_detail_id
            AND coverage_type    =coverage
            AND quote_header_id=quote;
           gen_xl_xml.write_cell_char( r,c, 'sheet1' , n, 'sgs2'  );
       end if;
  exception
    when others then
              gen_xl_xml.write_cell_char( r,c, 'sheet1' , 0, 'sgs2'  );

  end;

   function col return number is begin c:=c+1;return c;end;
   procedure heading(r varchar2,wd varchar2,nm varchar2)is
   begin
   GEN_XL_XML.SET_COLUMN_WIDTH(col,wd,v_work_sheet);
   GEN_XL_XML.WRITE_CELL_CHAR(r,c,v_work_sheet,nm,'BEN_PLAN_HEADER_BEN_PLAN');
   end;
   BEGIN

       for o in((
               SELECT account_type
                FROM ENTERPRISE A,ACCOUNT B
                WHERE a.entrp_id=b.entrp_id
                AND account_status=1
                AND id_verified   ='Y'
                 AND verified_by IS NOT null
               AND TRUNC(verified_date)>=trunc(sysdate-3)
              ---- AND TRUNC(verified_date)>=trunc(sysdate)
              group by account_type
              ) order by account_type
           )

      loop
           V_FILE_NAME:=replace(V_FILE_NAME_g,'#',o.account_type);
            --GEN_XL_XML.CREATE_EXCEL('GP',V_FILE_NAME);
           gen_xl_xml.create_excel('MAILER_DIR', V_FILE_NAME) ;
           gen_xl_xml.set_header;
           v_work_sheet:=o.account_type;
              r:=1; c:=0;
          l_col_tbl.delete;
           l_col_tbl(l_col_tbl.count+1)  := 'Name';
           l_col_tbl(l_col_tbl.count+1)  := 'Account Number';
           l_col_tbl(l_col_tbl.count+1)  := 'Product Type';
      	IF o.account_type IN ('FSA','HRA','FORM_5500') then
           l_col_tbl(l_col_tbl.count+1)  := 'Plan Name';
        END IF;
        l_col_tbl(l_col_tbl.count+1)  := 'Broker Name';
        l_col_tbl(l_col_tbl.count+1)  := 'GA Name';
        l_col_tbl(l_col_tbl.count+1)  := 'Sales Rep';
        l_col_tbl(l_col_tbl.count+1)  := 'Start Date';
        l_col_tbl(l_col_tbl.count+1)  := 'End Date';
        l_col_tbl(l_col_tbl.count+1)  := 'Total Eligible Employees';
        l_col_tbl(l_col_tbl.count+1)  := 'No of Employees';
        IF o.account_type IN ('FSA','HRA' ) then

           l_col_tbl(l_col_tbl.count+1)  := 'Card Allowed';
           l_col_tbl(l_col_tbl.count+1)  := 'Funding Option';
            l_col_tbl(l_col_tbl.count+1)  := 'Fees Paid By';
        END IF;

        IF o.account_type ='ERISA_WRAP' then
           l_col_tbl(l_col_tbl.count+1)  := 'Set Up Fee';
           l_col_tbl(l_col_tbl.count+1)  := 'Annual Fee';
        END IF;
        IF o.account_type='COBRA'then
             l_col_tbl(l_col_tbl.count+1) := 'Annual Fee/Monthly Fee';
             l_col_tbl(l_col_tbl.count+1) := 'Carrier Notification';
             l_col_tbl(l_col_tbl.count+1) := 'Open Enrollment Suite';
             l_col_tbl(l_col_tbl.count+1) := 'State Continuation Fees';
             l_col_tbl(l_col_tbl.count+1) := 'Billing Frequency';  --03/10/2020 Jagadeesh

        END IF;
         IF o.account_type='FORM_5500'then
           l_col_tbl(l_col_tbl.count+1) := 'Health  Form 5500';
           l_col_tbl(l_col_tbl.count+1) := 'Section 125 Plan Form 5500';
           l_col_tbl(l_col_tbl.count+1) := 'Health Reimbursement Account Plan Form 5500';
           l_col_tbl(l_col_tbl.count+1) := 'Form 5558 Extension';
           l_col_tbl(l_col_tbl.count+1) := 'Final Report';
           l_col_tbl(l_col_tbl.count+1) := 'Amend Past incorrect Insufficient Filings';
         END IF;
           l_col_tbl(l_col_tbl.count+1) := 'Total Fee';
           l_col_tbl(l_col_tbl.count+1) := 'Payment Method'   ;
           l_col_tbl(l_col_tbl.count+1) := 'Send Invoice to Broker/GA';
           l_col_tbl(l_col_tbl.count+1) := 'GA/Broker Email for Invoice';


         n :=0;

          FOR i IN 1 .. l_col_tbl.COUNT
          LOOP
             -- gen_xl_xml.write_cell_char( i,i, 'sheet1', l_col_tbl(i) ,'sgs1' );
             gen_xl_xml.write_cell_char( 1,i, 'sheet1' , l_col_tbl(i), 'sgs1'  );
             --dbms_output.put_line(' writing the headers for '||i || 'of '||l_col_tbl.COUNT);

          END LOOP;


          FOR i in(
            SELECT a.name
              ,b.ACC_NUM
              ,b.ACCOUNT_TYPE --begin of main 'select' clause
              ,(SELECT first_name from CONTACT_LEADS where upper(contact_type) = 'BROKER' and entity_id = a.entrp_code
                                                    and account_type = b.account_type and ref_entity_type = 'ONLINE_ENROLLMENT'
                                                    ) BROKER
              ,(SELECT first_name from CONTACT_LEADS where contact_type = 'GA' and entity_id = a.entrp_code
                                                    and account_type = b.account_type and ref_entity_type = 'ONLINE_ENROLLMENT'
                                                    ) ga
              ,PC_SALES_TEAM.GET_SALES_REP_NAME(B.SALESREP_ID)    salesrep
              ,to_char(d.plan_start_date,'mm/dd/rrrr') strt
              ,to_char(d.plan_end_date,'mm/dd/rrrr') endt
              ,(select census_numbers
                  from ENTERPRISE_CENSUS EC
                  where EC.census_code  = 'NO_OF_ELIGIBLE'
                  AND EC.ENTITY_TYPE ='ENTERPRISE'
                  AND EC.ENTITY_ID = A.ENTRP_ID) NO_OF_ELIGIBLE
              ,c.total_quote_price,
               c.payment_method,
               c.quote_header_id,
               d.ben_plan_id,
               d.ben_plan_name,
               decode(a.card_allowed,1,'Yes','No') card_allowed,
               CASE WHEN b.account_type = 'FORM_5500' THEN
                   (select census_numbers
                   from ENTERPRISE_CENSUS EC
                   where EC.census_code  = 'ACTIVE_PARTICIPANT'
                   AND EC.ENTITY_TYPE ='ENTERPRISE'
                   AND EC.ENTITY_ID = A.ENTRP_ID
                   AND EC.BEN_PLAN_ID(+) = D.BEN_PLAN_ID)
              ELSE
                  (select census_numbers
                  from ENTERPRISE_CENSUS EC
                  where EC.census_code  = 'NO_OF_EMPLOYEES'
                  AND EC.ENTITY_TYPE ='ENTERPRISE'
                  AND EC.ENTITY_ID = A.ENTRP_ID)
              END  no_of_employees,
               null   funding_option,
              (SELECT listagg(cl.email,',') within group(order by 1)from contact_leads cl
               WHERE cl.send_invoice in ('1','Y')
               and upper(cl.contact_type) in('BROKER','GA')--extract send invoice email address
               and cl.account_type=b.account_type
               AND cl.ref_entity_type = 'ONLINE_ENROLLMENT'
               AND (cl.ref_entity_id=d.ben_plan_id or cl.entity_id=a.entrp_code))email,
             (SELECT fees_paid_by from account_preference where acc_id = b.acc_id) pay_acct_fees,Decode(Billing_frequency,'A','Annual','M','Monthly',Null,'Annual') Billing_frequency   -- 03/10/2020 Jagadeesh
          FROM ENTERPRISE A,ACCOUNT B,ar_quote_headers c,ben_plan_enrollment_setup d --quote is 'with' clause
          WHERE A.entrp_id = b.entrp_id
          AND   b.entrp_id = c.entrp_id
          AND  b.acc_id = d.acc_id
          --AND   c.ben_plan_id= d.ben_plan_id(+)
          and   b.account_type =o.account_type
          AND   b.account_status=1
          AND   b.id_verified   ='Y'
          AND   B.account_type NOT IN ('HRA','FSA', 'HSA')
          AND   b.verified_by IS NOT null
          AND   TRUNC(b.verified_date) >=trunc(sysdate-3)
          --AND   TRUNC(b.verified_date) >=trunc(sysdate)
          UNION
          SELECT a.name
              ,b.ACC_NUM
              ,b.ACCOUNT_TYPE --begin of main 'select' clause
              ,(SELECT first_name from CONTACT_LEADS where upper(contact_type) = 'BROKER' and entity_id = a.entrp_code
                                                    and account_type = b.account_type ) BROKER
              ,(SELECT first_name from CONTACT_LEADS where contact_type = 'GA' and entity_id = a.entrp_code
                                                    and account_type = b.account_type) ga
              ,PC_SALES_TEAM.GET_SALES_REP_NAME(B.SALESREP_ID) salesrep
              ,to_char(d.plan_start_date,'mm/dd/rrrr') strt
              ,to_char(d.plan_end_date,'mm/dd/rrrr') endt
               ,A.no_of_eligible
             --,null no_of_eligible
              ,null total_quote_price
              ,(Select payment_method from ONLINE_FSA_HRA_STAGING where entrp_id = a.entrp_id) payment_method
              , NULL quote_header_id
               ,d.ben_plan_id
               ,d.ben_plan_name
               ,decode(a.card_allowed,1,'No','Yes') card_allowed
               ,(select census_numbers
                  from ENTERPRISE_CENSUS EC
                  where EC.census_code  = 'NO_OF_EMPLOYEES'
                  AND EC.ENTITY_TYPE ='ENTERPRISE'
                  AND EC.ENTITY_ID = A.ENTRP_ID) no_of_employees,
                case when d.product_type = 'HRA' THEN
                       pc_lookups.get_meaning(d.funding_options,'HRA_FUNDING_OPTION')
                when d.product_type = 'FSA' THEN
                       pc_lookups.get_meaning(d.funding_options,'FSA_FUNDING_OPTION')
                else null end funding_option,
              (SELECT listagg(cl.email,',') within group(order by 1)from contact_leads cl
               WHERE cl.send_invoice in ('1','Y')
               and upper(cl.contact_type) in('BROKER','GA')--extract send invoice email address
               and cl.account_type=b.account_type
               AND cl.ref_entity_type = 'ONLINE_ENROLLMENT'
               AND (cl.ref_entity_id=d.ben_plan_id or cl.entity_id=a.entrp_code))email,
               (SELECT  pay_acct_fees from online_fsa_hra_staging where entrp_id = a.entrp_id) pay_acct_fees,Null as Billing_frequency   -- Jagadeesh
          FROM ENTERPRISE A,ACCOUNT B, ben_plan_enrollment_setup d --quote is 'with' clause
          WHERE A.entrp_id = b.entrp_id
          AND   b.acc_id= d.acc_id
          and   b.account_type =o.account_type
          AND   b.account_status=1
          AND   b.id_verified   ='Y'
          AND   B.account_type  IN ('HRA','FSA')
          AND   b.verified_by IS NOT null
          AND   TRUNC(b.verified_date) >=trunc(sysdate-3)
          --AND   TRUNC(b.verified_date) >=trunc(sysdate)
          order by 2)--end of main 'select' clause
     LOOP
        --

           r := r+1;
           n := n+1;
           c:= 0;
           gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.name, 'sgs2'  );
           gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.acc_num, 'sgs2'  );
           gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.account_type, 'sgs2'  );
            IF i.account_type IN ('FSA','HRA','FORM_5500') then
              gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.ben_plan_name, 'sgs2'  );
           END IF;
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.broker, 'sgs2'  );
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.ga, 'sgs2'  );
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.salesrep, 'sgs2'  );
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.strt, 'sgs2'  );
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.endt, 'sgs2'  );
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.no_of_eligible, 'sgs2'  );
            gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.no_of_employees, 'sgs2'  );
           IF i.account_type IN ('FSA','HRA') then
                gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.card_allowed, 'sgs2'  );
                gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.funding_option, 'sgs2'  );
                gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.pay_acct_fees, 'sgs2'  );
           END IF;
           IF i.account_type='COBRA'then
               list_price(r,col,i.quote_header_id,'MAIN_COBRA_SERVICE'          );
               list_price(r,col,i.quote_header_id,'OPTIONAL_COBRA_SERVICE_CN'  );
               list_price(r,col,i.quote_header_id,'OPEN_ENROLLMENT_SUITE'     );
               list_price(r,col,i.quote_header_id,'OPTIONAL_COBRA_SERVICE_SC');
               gen_xl_xml.write_cell_char( r,col, 'sheet1' , i.Billing_frequency, 'sgs2'  );   --03/10/2020 Jagadeesh
           END IF;

           IF i.account_type='FORM_5500'then
               list_price(r,col,i.quote_header_id,'HEALTH_FRM'         );
               list_price(r,col,i.quote_header_id,'PLAN_FORM'         );
               list_price(r,col,i.quote_header_id,'HRA_ACCOUNT_FORM' );
               list_price(r,col,i.quote_header_id,'EXT_OF_FILE'     );
               list_price(r,col,i.quote_header_id,'FINAL_REPORT'   );
               list_price(r,col,i.quote_header_id,'INSUFF_FILLING');
           END IF;
           IF i.account_type='ERISA_WRAP'then
               list_price(r,col,i.quote_header_id,'SETUP_FEE'  );
               list_price(r,col,i.quote_header_id,'ANNUAL_FEE');
           END IF;

           GEN_XL_XML.WRITE_CELL_CHAR(r,col,'sheet1',i.total_quote_price,'sgs2');
           GEN_XL_XML.WRITE_CELL_CHAR(r,col,'sheet1',i.payment_method,  'sgs2');

           IF i.email IS NOT NULL THEN
             GEN_XL_XML.WRITE_CELL_CHAR(r,col,'sheet1','Yes',          'sgs2');
           ELSE
             GEN_XL_XML.WRITE_CELL_CHAR(r,col,'sheet1','No',          'sgs2');
           END IF;
           GEN_XL_XML.WRITE_CELL_CHAR(r,col,'sheet1',i.email,         'sgs2');
     END LOOP;
   GEN_XL_XML.CLOSE_FILE;

   IF FILE_EXISTS(V_FILE_NAME,'MAILER_DIR')='TRUE'THEN
          MAIL_UTILITY.SEND_FILE_IN_EMAILS(P_FROM_EMAIL   => 'oracle@sterlingadministration.com'
                                          ,P_TO_EMAIL     => V_EMAIL
                                          ,P_FILE_NAME    => V_FILE_NAME
                                          ,P_SQL          => NULL
                                          ,P_HTML_MESSAGE => replace(V_HTML_MSG,'#',o.account_type)
                                          ,P_REPORT_TITLE => 'Daily '||o.account_type||' New ER Invoice Report for the date '||TO_CHAR(SYSDATE,'MM/DD/YYYY'));
       END IF;
       end loop;
   EXCEPTION
       WHEN others then
           dbms_output.enable;
           dbms_output.put_line(sqlerrm);--||dbms_utility.format_call_stack);||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);

   END daily_new_er_invoice;

 PROCEDURE DAILY_RENEWAL_COBRA IS
       L_UTL_ID               UTL_FILE.FILE_TYPE;
       L_FILE_NAME            VARCHAR2(3200);
       L_LINE                 LONG;
       L_FILE_ID              NUMBER;
       NO_POSTING             EXCEPTION;
       L_renewal_fee          NUMBER := 0;
       l_carrier_pay          NUMBER := 0;
       l_carrier_notif        NUMBER := 0;
       l_open_enrll_suite     NUMBER := 0;
       l_pay_method           VARCHAR2(255);
       L_BROKER_CONTACT       VARCHAR2(4000);
       L_GA_CONTACT           VARCHAR2(4000);
       v_email                VARCHAR2(4000);

   BEGIN
             L_FILE_NAME := 'Daily_Renewal_COBRA_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.CSV';
             L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );

            L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start_date,End Date,'
           -- ||'Total COBRA Eligible Employees,' -- commented for enhancement
            ||'Renewal Amount,'
            ||'Carrier Notifications,Open Enrollment Suite,Payment Method'
            ||',Broker Contact,GA Contact';

             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );

            FOR X IN(SELECT A.NAME, B.ACC_NUM, B.BROKER_ID, B.GA_ID
                         , PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) BROKER_NAME
                         , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) GA_NAME
                         , TO_CHAR(ES.START_DATE,'mm/dd/rrrr')||','||TO_CHAR(ES.END_DATE,'mm/dd/rrrr') plandates
                         , PC_account.get_salesrep_name(B.AM_ID) rep_name
                         , a.no_of_eligible
                         , A.ENTRP_ID
                         , ES.RENEWAL_BATCH_NUMBER
                     FROM BEN_PLAN_RENEWALS ES, ENTERPRISE A,ACCOUNT B
                      WHERE ES.ACC_ID = B.ACC_ID
                     AND   A.ENTRP_ID = B.ENTRP_ID
                     AND   ES.PLAN_TYPE = 'COBRA'
                     AND   B.ACCOUNT_TYPE = 'COBRA'
                     AND TRUNC(ES.CREATION_DATE)>= TRUNC(SYSDATE-1))
            LOOP
                  L_renewal_fee           := 0;
                  l_carrier_pay           := 0;
                  l_carrier_notif         := 0;
                  l_open_enrll_suite      := 0;
                  L_BROKER_CONTACT        := NULL;
                  L_GA_CONTACT            := NULL;

                  L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||',COBRA,'||'"'||X.BROKER_NAME||'","'||X.GA_NAME
                          ||'","'||x.rep_name||'",'
                          ||X.plandates;
                          --||','||x.no_of_eligible;

                   FOR I IN (SELECT  c.LINE_LIST_PRICE PRICE
                                     ,RPD.COVERAGE_TYPE
                                     ,payment_method
                             FROM  AR_QUOTE_HEADERS B,AR_QUOTE_LINES C
                               ,   RATE_PLAN_DETAIL RPD
                             WHERE  C.RATE_PLAN_DETAIL_ID= RPD.RATE_PLAN_DETAIL_ID
                             AND    B.QUOTE_HEADER_ID=C.QUOTE_HEADER_ID
                             AND    B.BATCH_NUMBER = X.RENEWAL_BATCH_NUMBER
                              AND   B.ENTRP_ID = X.ENTRP_ID )
                   LOOP
                     IF I.COVERAGE_TYPE = 'MAIN_COBRA_SERVICE' THEN
                        L_renewal_fee   := i.PRICE;
                     END IF;
                     IF I.COVERAGE_TYPE = 'OPTIONAL_COBRA_SERVICE_CN' THEN
                        l_carrier_notif   := i.PRICE;
                     END IF;
                     IF I.COVERAGE_TYPE = 'OPEN_ENROLLMENT_SUITE' THEN
                        l_open_enrll_suite   := i.PRICE;
                     END IF;
                     IF I.COVERAGE_TYPE = 'OPTIONAL_COBRA_SERVICE_CP' THEN
                        l_carrier_pay   := i.PRICE;
                     END IF;
                      l_pay_method := i.payment_method;
                   END LOOP;

                   FOR J IN (SELECT  --- WM_CONCAT(FIRST_NAME) FIRST_NAME --- Commented by RPRABU 0n 17/10/2017
                             LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME)  FIRST_NAME  -- Added by RPRABU 0n 17/10/2017
                             FROM
                             (SELECT DISTINCT FIRST_NAME FIRST_NAME
                                FROM CONTACT_LEADS
                               WHERE CONTACT_TYPE     = 'BROKER'
                                 AND REF_ENTITY_ID    = X.RENEWAL_BATCH_NUMBER
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_RENEWALS')) LOOP
                        L_BROKER_CONTACT := '"'||J.FIRST_NAME||'"';
                   END LOOP;

                   FOR J IN (SELECT ---   WM_CONCAT(FIRST_NAME) FIRST_NAME
                             LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME)  FIRST_NAME  -- Added by RPRABU 0n 17/10/2017
                             FROM
                            (SELECT DISTINCT FIRST_NAME FIRST_NAME
                               FROM CONTACT_LEADS
                              WHERE CONTACT_TYPE      = 'GA'
                                 AND REF_ENTITY_ID    = X.RENEWAL_BATCH_NUMBER
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_RENEWALS')) LOOP
                        L_GA_CONTACT := '"'||J.FIRST_NAME||'"';
                    END LOOP;

                    L_LINE := l_line ||','||NVL(L_renewal_fee,0)||','||
                                     NVL(l_carrier_pay,0)||','||NVL(l_open_enrll_suite,0)||','||l_pay_method
                                     ||','||REPLACE(REPLACE(L_BROKER_CONTACT,'>',''),'<','')||','
                                     ||REPLACE(REPLACE(L_GA_CONTACT,'>',''),'<','');

                   UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );
            END LOOP;

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);
            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE' THEN
             IF USER = 'SAM' THEN
                 V_email :=  'cobra@sterlingadministration.com,implementation@sterlingadministration.com'||
                             ',dan.tidball@sterlingadministration.com,AccountManagement@sterlingadministration.com'||
                             ',IT-Team@sterlingadministration.com';

               ELSE
                 V_email :=  'IT-team@sterlingadministration.com';

               END IF;
                mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => V_email
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'COBRA Renewals for '||to_char(sysdate,'MM/DD/YYYY'));
            END IF;



    EXCEPTION
         WHEN NO_POSTING THEN
              NULL;
         WHEN OTHERS THEN
              raise;
   END DAILY_RENEWAL_COBRA;
   -- This report will be sent to compliance team along with sales team and others in executive committee

  PROCEDURE DAILY_RENEWAL_ERISA IS
       L_UTL_ID               UTL_FILE.FILE_TYPE;
       L_FILE_NAME            VARCHAR2(3200);
       L_LINE                 LONG;
       L_FILE_ID              NUMBER;
       NO_POSTING             EXCEPTION;
       CNT                    NUMBER;
       L_ACC_ID               NUMBER;
       L_BROKER_ID            NUMBER;
       L_GA                   NUMBER;
       L_BROKER_FLAG          VARCHAR2(50);
       L_GA_FLAG              VARCHAR2(50);

       L_NAME                 VARCHAR2(50);
       L_LIC                  VARCHAR2(20);
       L_CONTACT              VARCHAR2(50);
       L_CONTACT1             VARCHAR2(1000);
       l_entity_type          VARCHAR2(50);
       l_ben_plan_number      VARCHAR2(20);
       l_clm_lang             VARCHAR2(20);
       l_grandfathered        VARCHAR2(20);
       l_ben_code             VARCHAR2(1000);
       L_BROKER_CONTACT       VARCHAR2(4000);
       L_GA_CONTACT           VARCHAR2(4000);
        v_email                VARCHAR2(4000);
       l_count                number := 0;
       L_ben_code_count       number := 0;

   BEGIN
             L_FILE_NAME := 'Daily_Renewal_Erisa_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.CSV';

            L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );

            L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,'
            ||'Plan Start Date,Plan End Date,Welfare Benefit Plan Info,Plan Annual Renewal Fee,'
            ||'Form of Payment,Type of Entity,'
            ||'Affilitated Employers,Company Owned by another company,'
            ||'Health  Plan Number,The Wrap plan will include,'
            ||'Claims language included,Grandfather status,'
            ||'Total Number of Employees,Total Number of Eligible Employees (Updated),Sterling file Form 5500'
            ||',Responsible for paying ERISA Wrap account fees,Broker Contact,GA Contact,Special instructions';

             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );

            FOR X IN(SELECT A.NAME, B.ACC_NUM, B.BROKER_ID, B.GA_ID
                         , PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) BROKER_NAME
                         , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) GA_NAME
                         , TO_CHAR(PLAN_START_DATE,'mm/dd/rrrr')||','||TO_CHAR(PLAN_END_DATE,'mm/dd/rrrr') plandates
                         , BP.BEN_PLAN_NUMBER
                         , PC_LOOKUPS.GET_MEANING(NVL(ES.CLM_LANG_IN_SPD,'N'), 'YES_NO')  CLM_LANG_IN_SPD
                         , PC_LOOKUPS.GET_MEANING(NVL(ES.grandfathered ,'N'), 'YES_NO') grandfathered
                         , PC_LOOKUPS.GET_MEANING(ES.ENTITY_TYPE,'ENTITY_TYPE') ENTITY_TYPE
                         , PC_LOOKUPS.GET_MEANING(NVL(ES.AFFILIATED_ER,'N'), 'YES_NO') AFFILIATED_ER
                         , PC_LOOKUPS.GET_MEANING(NVL(ES.CONTROLLED_GROUP,'N'), 'YES_NO') CONTROLLED_GROUP
                         , ES.plan_include
                         , ES.note
                         , ES.NO_OF_EMPLOYEES
                         , ES.NO_OF_ELIGIBLE
                         , PC_LOOKUPS.GET_MEANING(NVL(ES.form55_opted,'N'), 'YES_NO') form55_opted
                         , BP.BEN_PLAN_ID
                         , A.ENTRP_ID
                         , PC_account.get_salesrep_name(B.AM_ID) rep_name
                         , BPR.PAY_ACCT_FEES
                         , B.ACC_ID
                         , BP.PLAN_END_DATE
                      FROM ONLINE_RENEWALS ES, ENTERPRISE A,ACCOUNT B
                         , BEN_PLAN_ENROLLMENT_SETUP BP
                         , BEN_PLAN_RENEWALS BPR
                     WHERE ES.ENTRP_ID = A.ENTRP_ID
                     AND   A.ENTRP_ID = B.ENTRP_ID
                     AND   ES.BEN_PLAN_ID = BP.BEN_PLAN_ID
                     AND   B.ACCOUNT_TYPE = 'ERISA_WRAP'
                     AND   BPR.RENEWED_PLAN_ID =BP.BEN_PLAN_ID
                     AND   ES.BEN_PLAN_ID = BPR.RENEWED_PLAN_ID
                     AND TRUNC(ES.CREATION_DATE)>= TRUNC(SYSDATE-1))
            LOOP
                 l_count := l_count+1;

                  L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||',ERISA,';
                  l_broker_flag := null;
                  l_ga_flag     := null;
                  IF X.BROKER_NAME IS NULL THEN

                    FOR J IN (SELECT AGENCY_NAME
                         FROM EXTERNAL_SALES_TEAM_LEADS
                             WHERE ENTITY_TYPE = 'BROKER'
                               and  entrp_id = X.ENTRP_ID
                               AND REF_ENTITY_ID    = X.BEN_PLAN_ID
                               AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')
                    LOOP
                          l_broker_flag := 'Y';
                          L_LINE := L_LINE ||'"'||   J.AGENCY_NAME||'",';
                    END LOOP;
                  ELSE
                  l_broker_flag := 'Y';
                      L_LINE := L_LINE ||'"'|| X.BROKER_NAME||'",';
                  END IF;
                 IF l_broker_flag IS NULL THEN
                    L_LINE := L_LINE ||',';
                 END IF;

                  IF X.GA_NAME IS NULL THEN

                    FOR J IN (SELECT AGENCY_NAME
                         FROM EXTERNAL_SALES_TEAM_LEADS
                             WHERE ENTITY_TYPE = 'GA'
                               and  entrp_id = X.ENTRP_ID
                               AND REF_ENTITY_ID    = X.BEN_PLAN_ID
                               AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')
                    LOOP
                          l_ga_flag := 'Y';
                          L_LINE := L_LINE ||'"'|| J.AGENCY_NAME||'","';
                    END LOOP;
                 ELSE
                          l_ga_flag := 'Y';

                      L_LINE := L_LINE ||'"'|| X.GA_NAME||'","';

                 END IF;
                 IF l_ga_flag IS NULL THEN
                    L_LINE := L_LINE ||',';
                 END IF;

                   L_LINE := L_LINE || x.rep_name||'",'
                          ||X.plandates;

                  l_broker_flag := null;
                  l_ga_flag     := null;
                  L_ben_code_count := 0;

                  -- check if last year benefit code is different from this year benefit code
                  FOR XXX IN (
                     SELECT COUNT(*) BEN_CODE_COUNT
                     FROM (SELECT   ( SELECT COUNT(*) FROM BENEFIT_CODES
                               WHERE ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
                               AND   BENEFIT_CODE_NAME = C.BENEFIT_CODE_NAME
                               AND   ENTITY_ID IN (SELECT MAX(BEN_PLAN_ID)
                                               FROM BEN_PLAN_ENROLLMENT_SETUP BPS
                                                WHERE BPS.ACC_ID = X.ACC_ID
                                                AND BPS.PLAN_END_DATE <= X.PLAN_END_DATE)
                               ) BEN_CODE_COUNT
                       FROM   BENEFIT_CODES C
                      WHERE   C.ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
                        AND   C.ENTITY_ID  = X.BEN_PLAN_ID)
                        WHERE BEN_CODE_COUNT = 0 )
                  LOOP
                     L_ben_code_count := xxx.BEN_CODE_COUNT;
                  END LOOP;
                  -- if we didnt find any setup last year , then check what got setup this year

                  IF l_ben_code_count = 0 THEN
                     FOR XXX IN (
                     SELECT COUNT(*) BEN_CODE_COUNT
                      FROM   BENEFIT_CODES C
                      WHERE   C.ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
                        AND   C.ENTITY_ID  = X.BEN_PLAN_ID)
                    LOOP
                        L_ben_code_count := xxx.BEN_CODE_COUNT;
                     END LOOP;
                  END IF;
                  L_LINE := L_LINE ||','||CASE WHEN L_ben_code_count > 0 THEN 'Yes' ELSE 'No' END;



                   FOR I IN (SELECT  c.LINE_LIST_PRICE PRICE
                                     ,RPD.COVERAGE_TYPE
                                     ,payment_method
                             FROM  AR_QUOTE_HEADERS B,AR_QUOTE_LINES C
                               ,   RATE_PLAN_DETAIL RPD
                             WHERE C.RATE_PLAN_ID= RPD.RATE_PLAN_ID
                             AND   C.RATE_PLAN_DETAIL_ID = RPD.RATE_PLAN_DETAIL_ID
                             AND   B.QUOTE_HEADER_ID=C.QUOTE_HEADER_ID
                             AND   B.BEN_PLAN_ID = X.BEN_PLAN_ID )
                   LOOP
                      L_LINE := L_LINE ||','||I.PRICE||','||I.payment_method;
                   END LOOP;

                   L_BROKER_CONTACT := NULL;
                   L_GA_CONTACT     := NULL;

                   FOR J IN (SELECT  --- WM_CONCAT(FIRST_NAME) FIRST_NAME  --- Commented by RPRABU 0n 17/10/2017
                             LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME)  FIRST_NAME -- Added by RPRABU 0n 17/10/2017
                              FROM
                             (SELECT DISTINCT  FIRST_NAME FIRST_NAME
                                FROM CONTACT_LEADS
                               WHERE CONTACT_TYPE     = 'BROKER'
                                 AND REF_ENTITY_ID    = X.BEN_PLAN_ID
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')) LOOP
                       L_BROKER_CONTACT := '"'||J.FIRST_NAME||'"';
                   END LOOP;

                   FOR J IN (SELECT  --- WM_CONCAT(FIRST_NAME) FIRST_NAME  --- Commented by RPRABU 0n 17/10/2017
                            LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME)  FIRST_NAME -- Added by RPRABU 0n 17/10/2017
                               FROM
                               (SELECT DISTINCT FIRST_NAME FIRST_NAME
                                  FROM CONTACT_LEADS
                                 WHERE CONTACT_TYPE     = 'GA'
                                   AND REF_ENTITY_ID    = X.BEN_PLAN_ID
                                   AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')) LOOP
                        L_GA_CONTACT := '"'||J.FIRST_NAME||'"';
                   END LOOP;

                   L_LINE := L_LINE ||','||x.entity_type
                          ||','||x.AFFILIATED_ER||','||x.CONTROLLED_GROUP||','||x.BEN_PLAN_NUMBER
                          ||','||x.plan_include||','||x.CLM_LANG_IN_SPD||','||x.grandfathered
                          ||','||NVL(x.NO_OF_EMPLOYEES,0)||','||NVL(x.NO_OF_ELIGIBLE,0)||','||x.form55_opted
                          ||','||x.pay_acct_fees
                          ||','||NVL(REPLACE(REPLACE(L_BROKER_CONTACT,'>',''),'<',''),'')
                          ||','||NVL(REPLACE(REPLACE(L_GA_CONTACT,'>',''),'<',''),'');
                   FOR XXX IN ( SELECT COUNT(*) NOTE_CNT
                                FROM  NOTES
                                WHERE NOTE_ACTION = 'SPECIAL_INSTRUCTIONS'
                                AND   ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
                                AND   ENTITY_ID = X.BEN_PLAN_ID)
                   LOOP
                      L_LINE := L_LINE ||','||CASE WHEN XXX.NOTE_CNT > 0 THEN 'Yes' ELSE 'No' END;
                   END LOOP;
                   UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );
            END LOOP;

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);
            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'
             AND l_count > 0 THEN
               IF USER = 'SAM' THEN
                 V_email :=  'compliance@sterlingadministration.com,implementation@sterlingadministration.com'||
                             ',dan.tidball@sterlingadministration.com,AccountManagement@sterlingadministration.com'||
                             ',IT-Team@sterlingadministration.com';

               ELSE
                 V_email :=  'IT-team@sterlingadministration.com';

               END IF;
                mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => V_email
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'ERISA Renewals for '||to_char(sysdate,'MM/DD/YYYY'));

              END IF;



    EXCEPTION
         WHEN NO_POSTING THEN
              NULL;
         WHEN OTHERS THEN
         RAISE;
                INSERT_ALERT('Error in creating COBRA Renewal File in Proc PC_WEB_COMPLIANCE.daily_renewal_cobra',SQLERRM||' '||SQLCODE);
   END DAILY_RENEWAL_ERISA;
       -- To be Sent to intake everyday

   PROCEDURE POP_RENEWALS IS
       L_UTL_ID               UTL_FILE.FILE_TYPE;
       L_FILE_NAME            VARCHAR2(3200);
       L_LINE                 LONG;
       L_FILE_ID              NUMBER;
       NO_POSTING             EXCEPTION;
       L_renewal_fee          NUMBER := 0;
       l_carrier_pay          NUMBER := 0;
       l_carrier_notif        NUMBER := 0;
       l_open_enrll_suite     NUMBER := 0;
       l_pay_method           NUMBER;
        v_email                VARCHAR2(4000);
       l_count                number := 0;

   BEGIN
             L_FILE_NAME := 'Renewal_Invoice_Due_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.CSV';

            L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );

            L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start_date,End Date';

             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );

            FOR X IN(select PC_ENTRP.GET_ENTRP_NAME(A.ENTRP_ID) NAME
                   , A.ACC_NUM
                   , ADD_MONTHS(B.PLAN_START_DATE,12)  PLAN_START_DATE
                   , ADD_MONTHS(B.PLAN_END_DATE,12) PLAN_END_DATE
                   , PC_BROKER.GET_BROKER_NAME(A.BROKER_ID) BROKER_NAME
                   , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(A.GA_ID) GA_NAME
                   , PC_account.get_salesrep_name(A.SALESREP_ID) rep_name
              from  account a, ben_plan_enrollment_setup b
              where account_type = 'POP' and plan_code= 512
              and   a.acc_id = b.acc_id
              and   b.plan_type ='NDT'
             and   b.plan_end_date = trunc(sysdate-90)
             and   b.plan_end_date =     '31-dec-2018'
              and   end_date is  null
              and   account_status = 1)
            LOOP
               l_count := l_count+1;

                  L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||','||'POP'||','||'"'||X.BROKER_NAME||'","'||X.GA_NAME
		           ||'","'||x.rep_name||'",'||to_char(x.PLAN_START_DATE,'MM/DD/YYYY')||','||to_char(x.PLAN_END_DATE,'MM/DD/YYYY');

                  UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );
            END LOOP;

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);
            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'
            AND l_count > 0 THEN
               IF USER = 'SAM' THEN
                 V_email :=  'compliance@sterlingadministration.com,VHS-Team@sterlingadministration.com'||
                             ',dan.tidball@sterlingadministration.com,sarah.soman@sterlingadministration.com';

               ELSE
                 V_email :=  'IT-team@sterlingadministration.com';

               END IF;
                mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => V_email
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'POP Renewals for '||to_char(sysdate,'MM/DD/YYYY'));
            END IF;



    EXCEPTION
         WHEN NO_POSTING THEN
              NULL;
         WHEN OTHERS THEN
                INSERT_ALERT('Error in creating POP Renewal File in Proc PC_WEB_COMPLIANCE.POP_RENEWALS',SQLERRM||' '||SQLCODE);
   END POP_RENEWALS;


  PROCEDURE DAILY_ONLINE_RENEWAL_INV_COBRA IS
         L_UTL_ID               UTL_FILE.FILE_TYPE;
         L_FILE_NAME            VARCHAR2(3200);
         L_LINE                 LONG;
         L_FILE_ID              NUMBER;
         NO_POSTING             EXCEPTION;
         L_renewal_fee          NUMBER := 0;
         l_carrier_pay          NUMBER := 0;
         l_carrier_notif        NUMBER := 0;
         l_open_enrll_suite     NUMBER := 0;
         l_pay_method           VARCHAR2(255);
         l_email                VARCHAR2(3200);
		 L_BILLING_FREQUNCY     VARCHAR2(100);
		 L_COBRAMonthly_ProcessingFee VARCHAR2(100); --8471 JAGADEESH
         /*To Check if records exist*/
         l_data_exist          VARCHAr2(2) := 'N';
         l_count                number := 0;
         l_broker_notify       VARCHAr2(2) := 'N';
     BEGIN
     dbms_output.put_line('Here');
               L_FILE_NAME := 'Daily_Online_Renewal_COBRA_Invoice_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.CSV';

              --L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );
     /*
              L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start_date,End Date,'
              ||'Total COBRA Eligible Employees,Renewal Amount,'
              ||'Carrier Notifications,Carrier Payment,Open Enrollment Suite,Payment Method, '
  	    ||'Send Invoice to Broker/GA, Broker/GA emails for Invoice ? ';

               UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                  BUFFER => L_LINE );
    */

              FOR X IN(SELECT A.NAME, B.ACC_NUM, B.BROKER_ID, B.GA_ID
                           --, PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) ACC_BROKER_NAME
                          --Ticket#4408.If Agenecy name is NULL then we display broker detail from ACCOUNT level
                           ,NVL((SELECT AGENCY_NAME
                           FROM EXTERNAL_SALES_TEAM_LEADS
                               WHERE ENTITY_TYPE = 'BROKER'
                                 and  entrp_id = a.entrp_id
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_RENEWALS'), PC_BROKER.GET_BROKER_NAME(B.BROKER_ID)) BROKER_NAME
                          -- , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) ACC_GA_NAME
                           --Ticket#4408
                            ,NVL((SELECT AGENCY_NAME
                           FROM EXTERNAL_SALES_TEAM_LEADS
                               WHERE ENTITY_TYPE = 'GA'
                                 and  entrp_id = a.entrp_id
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_RENEWALS'),PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID)) GA_NAME
                           , TO_CHAR(ES.START_DATE,'mm/dd/rrrr')||','||TO_CHAR(ES.END_DATE,'mm/dd/rrrr') plandates
                           , PC_account.get_salesrep_name(B.SALESREP_ID) rep_name
                           , a.no_of_eligible
                           , A.ENTRP_ID
                           , ES.RENEWAL_BATCH_NUMBER
                           , ES.PAY_ACCT_FEES
                       FROM BEN_PLAN_RENEWALS ES, ENTERPRISE A,ACCOUNT B
                        WHERE ES.ACC_ID = B.ACC_ID
                       AND   A.ENTRP_ID = B.ENTRP_ID
                       AND   ES.PLAN_TYPE = 'COBRA'
                       AND   B.ACCOUNT_TYPE = 'COBRA'
                       AND TRUNC(ES.CREATION_DATE)>= TRUNC(SYSDATE-1))
              LOOP
                 dbms_output.put_line('Loop');
                  /* We create a file only if data exist */
                   IF l_data_exist = 'N' THEN
                        L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );
                        L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start_date,End Date,'
                            ||'Total COBRA Eligible Employees,Renewal Amount,Billing Frequency,COBRA Monthly Processing Fee, ' --8471 JAGADEESH
                            ||'Carrier Notifications,Open Enrollment Suite,Payment Method, '
  	                        ||'Send Invoice to Broker/GA, Broker/GA emails for Invoice ?,Who will be responsible for paying Cobra account fee ? ';

                           UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                  BUFFER => L_LINE );
                   END IF;
                    l_count := l_count+1;
                    L_renewal_fee           := 0;
                    l_carrier_pay           := 0;
                    l_carrier_notif         := 0;
                    l_open_enrll_suite      := 0;
                    l_data_exist            := 'Y';

                    L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||',COBRA,'||'"'||X.BROKER_NAME||'","'||X.GA_NAME||'","'||x.rep_name||'",'
                            ||X.plandates||','||x.no_of_eligible;

                     FOR I IN (SELECT  c.LINE_LIST_PRICE PRICE
                                       ,RPD.COVERAGE_TYPE
                                       ,payment_method
									   ,DECODE(NVL(billing_frequency,'A'), 'A','Annual','Monthly') billing_frequency
                               FROM  AR_QUOTE_HEADERS B,AR_QUOTE_LINES C
                                 ,   RATE_PLAN_DETAIL RPD
                               WHERE  C.RATE_PLAN_DETAIL_ID= RPD.RATE_PLAN_DETAIL_ID
                               AND    B.QUOTE_HEADER_ID=C.QUOTE_HEADER_ID
                               AND    B.BATCH_NUMBER = X.RENEWAL_BATCH_NUMBER
                                AND   B.ENTRP_ID = X.ENTRP_ID )
                     LOOP
                       IF I.COVERAGE_TYPE = 'MAIN_COBRA_SERVICE' THEN
                          L_renewal_fee   := i.PRICE;
						  L_BILLING_FREQUNCY := i.billing_frequency ;
						  L_COBRAMonthly_ProcessingFee := 0; -- 8471 Jagadeesh
                          --- 8471 Jagadeesh
                          IF L_BILLING_FREQUNCY = 'Monthly' THEN
                             L_renewal_fee               := (L_renewal_fee-3);
                             L_COBRAMonthly_ProcessingFee:= 3;
                          END IF;
                          --
                       END IF;
                       IF I.COVERAGE_TYPE = 'OPTIONAL_COBRA_SERVICE_CN' THEN
                          l_carrier_notif   := i.PRICE;
                       END IF;
                       IF I.COVERAGE_TYPE = 'OPEN_ENROLLMENT_SUITE' THEN
                          l_open_enrll_suite   := i.PRICE;
                       END IF;
                       IF I.COVERAGE_TYPE = 'OPTIONAL_COBRA_SERVICE_CP' THEN
                          l_carrier_pay   := i.PRICE;
                       END IF;
                        l_pay_method := i.payment_method;
                     END LOOP;
                      L_LINE := l_line ||','||NVL(L_renewal_fee,0)||','||L_BILLING_FREQUNCY||','||L_COBRAMonthly_ProcessingFee||','||
                                       NVL(l_carrier_notif,0)||','||NVL(l_open_enrll_suite,0)||','||l_pay_method;

                      FOR xX IN ( SELECT  --- WM_CONCAT(EMAIL) EMAIL , --- Commented by RPRABU 0n 17/10/2017
                                  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL) EMAIL ,  -- Added by RPRABU 0n 17/10/2017
                                  DECODE(SEND_INVOICE,1,'Yes','No')SEND_INVOICE FROM CONTACT_LEADS
  		                           --WHERE REF_ENTITY_ID=  X.RENEWAL_BATCH_NUMBER
                                 WHERE ENTITY_ID = PC_ENTRP.GET_TAX_ID(X.ENTRP_ID) --Ticket#4408
  		                          	AND   REF_ENTITY_TYPE = 'BEN_PLAN_RENEWALS'
  		               	          	AND   SEND_INVOICE = '1'
                                  GROUP BY SEND_INVOICE)
                      LOOP
                          L_LINE := l_line ||','||xx.send_invoice||',"'||xx.email||'"';                      --L_LINE := l_line ||',Yes,"'||xx.email||'"';
                          l_broker_notify := 'Y';
  		                END LOOP;
                      IF l_broker_notify = 'N' THEN
                          L_LINE := l_line ||',,';
                      END IF;
                      L_LINE := l_line ||','||x.PAY_ACCT_FEES; --- added this for renewal phase 2
                     UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                  BUFFER => L_LINE );
              END LOOP;

              UTL_FILE.FCLOSE(FILE => L_UTL_ID);
              IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'

  	    AND l_count > 0 THEN
                 dbms_output.put_line('File Exist');

                 IF USER = 'SAM' THEN
                   l_email :=  'Sarah.Soman@sterlingadministration.com,VHSTeam@sterlingadministration.com'||
                               ',accountmanagement@sterlingadministration.com,accountrepresentatives@sterlingadministration.com'||
                               ',IT-team@sterlingadministration.com';

                 ELSE
                   l_email :=  'IT-team@sterlingadministration.com';

                 END IF;
                  mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                                ,  p_to_email  => l_email
                                                ,  p_file_name => l_file_name
                                                ,  p_sql       => null
                                                ,  p_html_message => null
                                                ,  p_report_title => 'COBRA  Online Renewal Invoice Report for  '||to_char(sysdate,'MM/DD/YYYY'));

              END IF;



      EXCEPTION
           WHEN NO_POSTING THEN
                NULL;
           WHEN OTHERS THEN
                raise;
   END DAILY_ONLINE_RENEWAL_INV_COBRA;

    PROCEDURE DAILY_ONLINE_RENEWAL_INV_ERISA IS
       L_UTL_ID               UTL_FILE.FILE_TYPE;
       L_FILE_NAME            VARCHAR2(3200);
       L_LINE                 LONG;
       L_FILE_ID              NUMBER;
       NO_POSTING             EXCEPTION;
       L_renewal_fee          NUMBER := 0;
       l_carrier_pay          NUMBER := 0;
       l_carrier_notif        NUMBER := 0;
       l_open_enrll_suite     NUMBER := 0;
       l_pay_method           VARCHAR2(255);
       l_email                VARCHAR2(3200);
       l_count                number := 0;
       l_broker_notify        VARCHAR2(1) := 'N';
   BEGIN
             L_FILE_NAME := 'Daily_Online_Renewal_ERISA_Invoice_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.CSV';

            L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );

            L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start_date,End Date,'
            ||'Total Eligible Employees,Renewal Amount,'
            ||'Bank Name,Payment Method, '
	          ||'Send Invoice to Broker/GA, Broker/GA emails for Invoice ?, '
            ||'Who will be responsible for paying ERISA account fee'; --- added this for renewal phase 2


             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );

            FOR X IN(SELECT A.NAME, B.ACC_NUM, B.BROKER_ID, B.GA_ID
                         , PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) BROKER_NAME
                         , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) GA_NAME
                         , TO_CHAR(ES.START_DATE,'mm/dd/rrrr')||','||TO_CHAR(ES.END_DATE,'mm/dd/rrrr') plandates
                         , PC_account.get_salesrep_name(B.SALESREP_ID) rep_name
                         , a.no_of_eligible
                         , A.ENTRP_ID
                         , ES.RENEWED_PLAN_ID
                         , ES.PAY_ACCT_FEES --- added this for renewal phase 2
                     FROM BEN_PLAN_RENEWALS ES, ENTERPRISE A,ACCOUNT B
                      WHERE ES.ACC_ID = B.ACC_ID
                     AND   A.ENTRP_ID = B.ENTRP_ID
                      AND   B.ACCOUNT_TYPE = 'ERISA_WRAP'
                     AND TRUNC(ES.CREATION_DATE)>= TRUNC(SYSDATE-1))
            LOOP
               l_count := l_count+1;
                  L_renewal_fee           := 0;
                   L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||',ERISA Wrap,'||'"'||X.BROKER_NAME||'","'||X.GA_NAME||'","'||x.rep_name||'",'
                          ||X.plandates||','||x.no_of_eligible;

                   FOR I IN (SELECT  c.LINE_LIST_PRICE PRICE
                                     ,RPD.COVERAGE_TYPE
                                     ,payment_method
				                            ,DECODE(B.PAYMENT_METHOD,'Check',null, pc_user_bank_acct.get_bank_name(B.BANK_ACCT_ID)) BANK_NAME
                             FROM  AR_QUOTE_HEADERS B,AR_QUOTE_LINES C
                               ,   RATE_PLAN_DETAIL RPD
                             WHERE  C.RATE_PLAN_DETAIL_ID= RPD.RATE_PLAN_DETAIL_ID
                             AND    B.QUOTE_HEADER_ID=C.QUOTE_HEADER_ID
                             AND    B.BEN_PLAN_ID = X.RENEWED_PLAN_ID
                              AND   B.ENTRP_ID = X.ENTRP_ID )
                   LOOP
                         L_renewal_fee   := i.PRICE;
                         l_pay_method := i.payment_method;
                         L_LINE := l_line ||','||NVL( i.PRICE,0)||','||
                                     i.bank_name||','||i.payment_method;

		   END LOOP;

                    FOR xX IN ( SELECT  --- WM_CONCAT(EMAIL) EMAIL ,                      -- Commented by RPRABU 0n 17/10/2017
                               LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL) EMAIL,   -- Added by RPRABU 0n 17/10/2017
                              DECODE(SEND_INVOICE,1,'Yes','No')SEND_INVOICE FROM CONTACT_LEADS
		                           WHERE REF_ENTITY_ID=  X.RENEWED_PLAN_ID
		                          	AND   REF_ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
		               	          	AND   SEND_INVOICE = '1'
                                GROUP BY SEND_INVOICE)
                    LOOP
                        L_LINE := l_line ||','||xx.send_invoice||',"'||xx.email||'"';
                        --L_LINE := l_line ||',Yes,"'||xx.email||'"';
                        l_broker_notify := 'Y';
		                END LOOP;
                    IF l_broker_notify = 'N' THEN
                        L_LINE := l_line ||',,';
                    END IF;
                    L_LINE := l_line ||','||X.PAY_ACCT_FEES; --- added this for renewal phase 2
                   UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );
            END LOOP;

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);

            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'
               AND l_count > 0 THEN

               IF USER = 'SAM' THEN
                  l_email :=  'compliance@sterlingadministration.com,VHSTeam@sterlingadministration.com'||
                             ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com,IT-team@sterlingadministration.com';

               ELSE
                l_email :=  'IT-Team@sterlingadministration.com';
               END IF;
                mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => l_email
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'ERISA Online Renewal Invoice Report for '||to_char(sysdate,'MM/DD/YYYY'));

            END IF;



    EXCEPTION
         WHEN NO_POSTING THEN
              NULL;
         WHEN OTHERS THEN
              raise;
   END DAILY_ONLINE_RENEWAL_INV_ERISA;
      PROCEDURE PAST_DUE_RENEWALS IS
       L_UTL_ID               UTL_FILE.FILE_TYPE;
       L_FILE_NAME            VARCHAR2(3200);
       L_LINE                 LONG;
       L_FILE_ID              NUMBER;
       NO_POSTING             EXCEPTION;
       L_renewal_fee          NUMBER := 0;
       l_carrier_pay          NUMBER := 0;
       l_carrier_notif        NUMBER := 0;
       l_open_enrll_suite     NUMBER := 0;
       l_pay_method           NUMBER;
       v_email                VARCHAR2(4000);
       l_count                number := 0;
   BEGIN
             L_FILE_NAME := 'Renewal_Invoice_Due_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.CSV';

            L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );

            L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start_date,End Date'
            ||',Invoice #';

             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );

            FOR X IN(SELECT A.NAME, B.ACC_NUM, B.BROKER_ID, B.GA_ID, B.ACCOUNT_TYPE
                         , PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) BROKER_NAME
                         , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) GA_NAME
                         , TO_CHAR(ES.START_DATE,'mm/dd/rrrr')||','||TO_CHAR(ES.END_DATE,'mm/dd/rrrr') plandates
                         , PC_account.get_salesrep_name(B.SALESREP_ID) rep_name
                         , A.ENTRP_ID
			                   , ES.CREATION_DATE
		                   	 , B.ACC_ID
                     FROM BEN_PLAN_RENEWALS ES, ENTERPRISE A,ACCOUNT B
                      WHERE ES.ACC_ID = B.ACC_ID
                     AND   A.ENTRP_ID = B.ENTRP_ID
                     AND   ES.PLAN_TYPE in ('ERISA_WRAP', 'COBRA')
                     AND   B.ACCOUNT_TYPE in ('ERISA_WRAP', 'COBRA')
                     AND TRUNC(ES.CREATION_DATE)> TRUNC(SYSDATE-1))
            LOOP

               l_count := l_count+1;
                  L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||','||X.ACCOUNT_TYPE||','||'"'||X.BROKER_NAME||'","'||X.GA_NAME
		           ||'","'||x.rep_name||'",'||X.plandates;

                  FOR K IN ( SELECT invoice_id FROM AR_INVOICE WHERE acc_id =X.ACC_ID AND CREATION_DATE > X.CREATION_DATE)
		               LOOP
                     L_LINE := L_LINE ||','||K.INVOICE_ID;
		               END LOOP;
                  UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                BUFFER => L_LINE );
            END LOOP;

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);
            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'
            AND l_count > 0
            THEN
               IF USER = 'SAM' THEN
                 v_email :=  'compliance@sterlingadministration.com,cobra@sterlingadministration.com'||
                             ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com';

               ELSE
                 v_email :=  'IT-team@sterlingadministration.com';

               END IF;
                mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => v_email
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'COBRA/ERISA past due Renewals for '||to_char(sysdate,'MM/DD/YYYY'));
            END IF;



    EXCEPTION
         WHEN NO_POSTING THEN
              NULL;
         WHEN OTHERS THEN
                INSERT_ALERT('Error in creating COBRA Renewal File in Proc PC_WEB_COMPLIANCE.daily_renewal_cobra',SQLERRM||' '||SQLCODE);
   END PAST_DUE_RENEWALS;

 PROCEDURE WEBFORM_ER_DAILY_NOTFICATION
is
L_HTML_MESSAGE VARCHAR2(32000) ;
L_NOTIFICATION_ID NUMBER;
L_ENTRP_EMAIL VARCHAR2(250);
L_ENTRP_ID NUMBER;
L_USER_ID NUMBER ;
l_sql     VARCHAR2(32000);
begin

for X in ( SELECT DISTINCT E.ENTRP_EMAIL, O.ENTRP_ID
FROM ONLINE_ENROLLMENT O, ENTERPRISE E
WHERE O.ENTRP_ID = E.ENTRP_ID
AND ENROLLMENT_SOURCE = 'WEBFORM_ENROLL' AND ENROLLMENT_STATUS = 'S'
AND TRUNC(O.CREATION_DATE)= TRUNC(SYSDATE)-1 )
LOOP
L_ENTRP_EMAIL := x.ENTRP_EMAIL ;
L_ENTRP_ID := x.ENTRP_ID ;

L_HTML_MESSAGE  := '<br/><br/> Dear Employer, </br>
               <p> Thank you for completing the online enrollment of your employee(s) in your benefit plan(s). </p>
               <p> Please find the attached file with the list of employees that you successfully enrolled and their corresponding plan information. </p>
               <p> Please keep this email for your records. </p>
               <p> If you have any questions regarding your account, please do not hesitate to contact our Customer Service department at 800-617-4729 or send an email to ClientServices@sterlingadministration.com. </p> ';

l_sql :=  ' select E.FIRST_NAME "first Name"
       ,E.LAST_NAME "Last Name"
       ,a.ACC_NUM "Sterling Account Number"
       ,C.PLAN_TYPE "Plan Type"
       ,TO_CHAR(C.PLAN_START_DATE,''mm/dd/yyyy'') || '' - '' || TO_CHAR(C.PLAN_END_DATE,''mm/dd/yyyy'') PLAN_PERIOD
       ,decode( PC_LOOKUPS.GET_meaning(C.PLAN_TYPE,''FSA_HRA_PRODUCT_MAP''),''FSA'', b.annual_election,null) "Annual Election"
       ,decode( PC_LOOKUPS.GET_meaning(C.PLAN_TYPE,''FSA_HRA_PRODUCT_MAP''),''HRA'', b.annual_election,null) "Coverage Tier Amount"
       ,b.covg_tier_name "Coverage Type"
       ,b.EFFECTIVE_DATE  "Payroll Effective Date"
       ,b.first_payroll_date "First Payroll Date"
       ,b.pay_contrb "Per pay period amount"
       ,DECODE(IS_NUMBER(b.pay_cycle), ''Y'',(SELECT DISTINCT FREQUENCY
                                       FROM   PAYROLL_CALENDAR
                                       WHERE  SCHEDULER_ID = b.pay_cycle), b.pay_cycle)  "Calendar frequency"

        from account a, ONLINE_ENROLL_PLANS B, BEN_PLAN_ENROLLMENT_SETUP C,ONLINE_ENROLLMENT E
    where C.BEN_PLAN_ID_MAIN = B.ER_BEN_PLAN_ID
     and a.ACCOUNT_TYPE in (''HRA'',''FSA'')
     and  C.ACC_ID = a.ACC_ID
     and B.ENROLLMENT_ID = E.ENROLLMENT_ID
     and a.ACC_ID = E.ACC_ID
     and E.ENTRP_ID = ' || L_ENTRP_ID ||
          ' AND E.ENROLLMENT_SOURCE = ''WEBFORM_ENROLL'' and E.ENROLLMENT_STATUS = ''S''
          AND TRUNC(E.CREATION_DATE)= TRUNC(SYSDATE)-1' ;
    --  dbms_output.put_line(l_sql) ;
     FOR y IN (select  LISTAGG(email, ',') WITHIN GROUP (ORDER BY user_name) emails
       from online_users
       where  user_status = 'A' and emp_reg_type <> 1  AND replace(tax_id,'-') =
       (select entrp_code from enterprise where entrp_id =  L_ENTRP_ID))
   LOOP
    --dbms_output.put_line(y.emails) ;

     mail_utility.report_emails('ClientServices@sterlingadministration.com'
                           , y.emails
                           ,'Daily Employee Enrollment_'||to_char(L_ENTRP_ID)||'_'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Employee Enrollment Confirmations in your benefit plan');

     mail_utility.report_emails('oracle@sterlingadministration.com'
                           , 'ClientServices@sterlingadministration.com,VHSTeam@sterlingadministration.com'
                           ,'Daily Employee Enrollment_'||to_char(L_ENTRP_ID)||'_'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Employee Enrollment Confirmations in your benefit plan');


     END LOOP;
END LOOP;

END WEBFORM_ER_DAILY_NOTFICATION;
/*Ticket 4286 */
/*Ticket 4286 */
PROCEDURE notify_approved_claims
    IS
      L_EVENT_TYPE VARCHAR2(30);
      l_return_status VARCHAR2(255) := 'S';
      l_error_message VARCHAR2(255);
      l_error         EXCEPTION;
      l_process_flag  VARCHAR2(255) := 'N';
      l_notif_id      NUMBER;
      l_acc_id NUMBER;
        num_tbl number_tbl;

   BEGIN
     --  claim is fully approved

   FOR XX IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.cc_address
                  ,  e.email email
                  ,  e.entity_id
                  ,  e.acc_num
                  ,  e.event_id
                  ,  c.approved_amount
                  ,  c.claim_amount
                  ,  pc_entrp.get_entrp_name(c.entrp_id) er_name
                  ,  D.FIRST_NAME||' '||D.LAST_NAME pers_name
                  ,  pc_lookups.get_fsa_plan_type(c.service_type) plan_type
                  ,  pc_person.acc_id(c.pers_id) acc_id
                  , c.pers_id
              FROM   NOTIFICATION_TEMPLATE A
                    ,  EVENT_NOTIFICATIONS E
                    ,  CLAIMN C
                    ,  PERSON D
              WHERE  A.TEMPLATE_NAME = E.TEMPLATE_NAME
                AND    E.EVENT_NAME  = 'CLAIM_APPROVED'
                AND    A.STATUS = 'A'
                and    c.claim_id = e.entity_id
                AND    D.PERS_ID = C.PERS_ID
                AND    NVL(E.PROCESSED_FLAG,'N') = 'N'
                AND    E.EVENT_TYPE = 'EMAIL'
                AND    E.ENTITY_TYPE= 'CLAIMN'
    )
 LOOP

	                 PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
	                 (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
	                 ,P_TO_ADDRESS   => xx.email
	                 ,P_CC_ADDRESS   => xx.cc_address
	                 ,P_SUBJECT      => xx.template_subject
	                 ,P_MESSAGE_BODY => xx.template_body
	                 ,P_USER_ID      => 0
	                 ,P_ACC_ID     => xx.acc_id
                 ,X_NOTIFICATION_ID => l_notif_id );

          select user_id bulk collect into num_tbl
          from online_users where replace(tax_id,'-')=
	                 (select replace(ssn,'-')from person
                    where pers_id=xx.pers_id);
          add_notify_users(num_tbl,l_notif_id);



		PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',xx.acc_num,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',xx.pers_name,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('DATE',SYSDATE,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_ID',xx.entity_id,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT',xx.claim_amount,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('APPROVED_AMOUNT',xx.approved_amount,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.er_name,l_notif_id);
		PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',xx.plan_type,l_notif_id);


          UPDATE EMAIL_NOTIFICATIONS
          SET    MAIL_STATUS = 'READY'
          WHERE  NOTIFICATION_ID  = l_notif_id;
         pc_log.log_error('processing insert,l_notif_id ',l_notif_id);

           UPDATE EVENT_NOTIFICATIONS
            SET   processed_flag = 'Y'
           WHERE  event_id  = xx.event_id;

   END LOOP;

     exception
     WHEN OTHERS THEN
  -- Close the file if something goes wrong.

      dbms_output.put_line('error message '||SQLERRM);
  END notify_approved_claims;
PROCEDURE insert_approved_claim_events
  (P_CLAIM_ID          IN NUMBER
  ,P_USER_ID           IN NUMBER)
  IS
    L_EVENT_TYPE VARCHAR2(30);
    l_return_status VARCHAR2(255) := 'S';
    l_error_message VARCHAR2(255);
    l_error         EXCEPTION;
    l_process_flag  VARCHAR2(255) := 'N';
 BEGIN
   --  claim is fully denied
   pc_log.log_error('PC_NOTIFICATIONS: insert_approved_claim_events,x.service_type ', P_CLAIM_ID  );

   FOR X IN ( SELECT nvl(pc_users.get_email(a.acc_num, a.acc_id, b.pers_id),e.email) email
                    ,b.claim_id
                    ,a.acc_id
                    ,a.acc_num
                    ,b.pers_id
                    ,b.claim_status status
               FROM   payment_register a
                  ,  claimn b
                  ,  person e
              WHERE   b.claim_id = p_claim_id
              AND     a.claim_id = b.claim_id
              AND     e.pers_id= b.pers_id
              AND     b.claim_status ='APPROVED'
         )
   LOOP
        pc_log.log_error('PC_NOTIFICATIONS: insert_approved_claim_events,x.email ', x.email  );

         IF x.email IS NOT NULL THEN
             L_EVENT_TYPE := 'EMAIL';
         END IF;
          --Send patial denial notifications also.
       IF x.status = 'APPROVED' AND x.email is NOT NULL THEN /* If Email is NULL we will not insert */
          INSERT_EVENT_NOTIFICATIONS
         (P_EVENT_NAME   => 'CLAIM_APPROVED'
         ,P_EVENT_TYPE   => L_EVENT_TYPE
         ,P_EVENT_DESC   => 'Full Claim approved for '||x.acc_num
         ,P_ENTITY_TYPE  => 'CLAIMN'
         ,P_ENTITY_ID    => x.claim_id
         ,P_ACC_ID       => x.acc_id
         ,P_ACC_NUM      => x.acc_num
         ,P_PERS_ID      => x.pers_id
         ,P_USER_ID      => P_USER_ID
         ,P_EMAIL        => x.email
         ,P_TEMPLATE_NAME => 'CLAIM_APPROVAL'
         ,X_RETURN_STATUS => l_return_status
         ,X_ERROR_MESSAGE => l_error_message);
       END IF;
             IF l_return_status <> 'S' THEN
                ROLLBACK;
                RAISE  l_error;
             END IF;
   END LOOP;
exception
   WHEN OTHERS THEN
-- Close the file if something goes wrong.
    dbms_output.put_line('error message '||SQLERRM);
  END insert_approved_claim_events;

  -- Added by Joshi fort 5024/5164.
 procedure SEND_UPLOADFILE_NOTIFY(P_ACCOUNT_TYPE varchar2, P_ACC_NUM varchar2, P_FILE_NAMES VARCHAR2_TBL, P_BROKER_ID number)
is
    l_html_message      VARCHAR2(32000) ;
    l_notification_id   NUMBER;
    l_to_email_id       VARCHAR2(250);
    l_cc_email_id       VARCHAR2(250);
    l_file_names        VARCHAR2_TBL;
    l_file_list         VARCHAR2(2000);
	L_Desc              VARCHAR2(250);   -- Added by Swamy for Ticket#7660
    l_subject_name      VARCHAR2(250);   -- Added by Joshi for 10974
    L_entrp_id         Varchar2(100);  ---L_entrp_id added by rprabu 07/04/2025 INC24001
    begin
---  added by rprabu 02/04/2025 
             PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: SEND_UPLOADFILE_NOTIFY 101  P_ACCOUNT_TYPE  ', P_ACCOUNT_TYPE  );
             PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: SEND_UPLOADFILE_NOTIFY 102   User  ', User  ); 

    -- Added by Joshi for 10974  ---L_entrp_id added by rprabu 07/04/2025 
    FOR X IN (SELECT Entrp_Id    
                FROM ACCOUNT
               WHERE ACC_NUM = P_ACC_NUM)
    LOOP
        l_subject_name := 'Documents uploaded for '||pc_entrp.get_entrp_name (x.entrp_id) ||'('||pc_entrp.get_acc_num(x.entrp_id) ||')' ;
        L_entrp_id := X.Entrp_Id ;    ----  L_entrp_id added by rprabu  07/04/2025 INC24001
    END LOOP;

    IF l_subject_name IS NULL THEN
        l_subject_name := 'Documents uploaded';
    END IF;
    --

    L_FILE_NAMES := ARRAY_FILL(P_FILE_NAMES,P_FILE_NAMES.count);

    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: send_uploadfile_notify file list', L_FILE_NAMES.count  );

    L_FILE_LIST := '<ul>';
    for i in 1 .. L_FILE_NAMES.count
    loop
     L_FILE_LIST :=  L_FILE_LIST || '<li> ' ||  L_FILE_NAMES(i) || ' </li>';
    end loop;

     L_FILE_LIST := L_FILE_LIST ||'</ul>';

    L_HTML_MESSAGE  := 'Hello, </br> ' ;

    if P_ACCOUNT_TYPE is null and P_BROKER_ID is not null then
        --L_HTML_MESSAGE := L_HTML_MESSAGE || '<p>The below W-9 document(s) are uploaded for Broker(' || P_BROKER_ID ||').</p>' ;  -- Commented by swamy for Ticket#7660.

	   -- Added by swamy for Ticket#7660.
       -- Get the Description of the kind of document uploaded.
	   -- Entity_Id is Varchar2 type and broker_Id is Number Type, hence using TO_CHAR
       FOR j IN (SELECT Description FROM File_Attachments
                              WHERE Entity_Id     = P_Broker_Id
							  AND   entity_name = 'BROKER'
                              ORDER BY Attachment_Id DESC
       )
       LOOP
       L_Desc := J.Description;
       EXIT;
       END LOOP;
       L_HTML_MESSAGE := L_HTML_MESSAGE || '<p>The below '||L_Desc||' document is uploaded for Broker(' || P_BROKER_ID ||').</p>' ;  -- Added by Swamy for Ticket#7660
       -- Code ends for Ticket#7660.
       L_HTML_MESSAGE  := L_HTML_MESSAGE || L_FILE_LIST  ;
    else
        L_HTML_MESSAGE := L_HTML_MESSAGE || '<p>The below plan document(s) are uploaded for the Employer(' || P_ACC_NUM || ') to their plan. </p>' ;
        L_HTML_MESSAGE  := L_HTML_MESSAGE || L_FILE_LIST  ;
        L_HTML_MESSAGE  := L_HTML_MESSAGE || '<p> Please log in to SAM and navigate to the Service Documents module to view.</p> ';
    end if;

    IF 	P_ACCOUNT_TYPE = 'ERISA_WRAP' OR 	P_ACCOUNT_TYPE = 'FORM_5500'  OR 	P_ACCOUNT_TYPE = 'POP'  THEN
       IF user = 'SAM' THEN
          L_TO_EMAIL_ID := 'compliance@sterlingadministration.com,accountrepresentative@sterlingadministration.com'; -- Added by Jaggi #11264
          --L_TO_EMAIL_ID := 'IT-team@sterlingadministration.com' ;
          L_CC_EMAIL_ID := 'IT-team@sterlingadministration.com,vhsteam@sterlingadministration.com';
       ELSE
         L_TO_EMAIL_ID := 'jagadeesh.reddy@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,pooja.kc@sterlingadministration.com,vhsteam@sterlingadministration.com';
         L_CC_EMAIL_ID := 'raghavendra.joshi@sterlingadministration.com,Dhanya.Kumar@sterlingadministration.com';
       END IF;

    ELSIF P_ACCOUNT_TYPE = 'HRA' OR P_ACCOUNT_TYPE = 'FSA'  THEN
        IF user = 'SAM' THEN
            L_TO_EMAIL_ID := 'benefits@sterlingadministration.com,accountrepresentative@sterlingadministration.com'; -- Added by Jaggi #11264
            --L_TO_EMAIL_ID := 'IT-team@sterlingadministration.com' ;
            L_CC_EMAIL_ID := 'IT-team@sterlingadministration.com,vhsteam@sterlingadministration.com';
        ELSE
            L_TO_EMAIL_ID := 'jagadeesh.reddy@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,pooja.kc@sterlingadministration.com,vhsteam@sterlingadministration.com';
            L_CC_EMAIL_ID := 'raghavendra.joshi@sterlingadministration.com,Dhanya.Kumar@sterlingadministration.com';
         END IF;

  Elsif p_account_type = 'COBRA' then  
        ---  added by rprabu 07/04/2025  INC24001 
        FOR z IN ( 
                    select b.Email From Sales_Team_Member a , employee B 
                    where emplr_id =L_entrp_id and entity_type ='CS_REP' and status ='A' 
                    and a.Entity_id  =b.emp_id 
                 )
        LOOP
            l_to_email_id :=  z.email ;    -------- added by rprabu 07/04/2025  INC24001 
        END LOOP; 

         l_to_email_id := nvl(l_to_email_id, 'cobra@sterlingadministration.com' ) ;  --- rprabu 07/04/2025 INC24001

        IF user = 'SAM' THEN
             --    L_TO_EMAIL_ID := 'cobra@sterlingadministration.com,vhsteam'; -- Added by Jaggi #11264
              ---- ---NVL  added by rprabu 02/04/2025  
              L_TO_EMAIL_ID := Nvl(L_TO_EMAIL_ID, 'cobra@sterlingadministration.com,vhsteam@sterlingadministration.com'); -- removed accountrepresentative by joshi for prod issue.
              L_CC_EMAIL_ID := 'vhscobraprocessingteam@sterlingadministration.com,it-team@sterlingadministration.com'; 
          ELSE
           -- L_TO_EMAIL_ID := Nvl(L_TO_EMAIL_ID, 'cobra@sterlingadministration.com,vhsteam@sterlingadministration.com'); -- removed accountrepresentative by joshi for prod issue.
            --L_CC_EMAIL_ID := 'it-team@sterlingadministration.com,testelse@test123.com'; 
              L_TO_EMAIL_ID := 'it-team@sterlingadministration.com';   
         END IF;

         PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: send_uploadfile_notify  ELse  l_to_email_id 503  : ', l_to_email_id  );
         PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: send_uploadfile_notify  ELse L_CC_EMAIL_ID   503.5  : ', L_CC_EMAIL_ID  );
    ELSE
        IF user = 'SAM' THEN
            L_TO_EMAIL_ID := 'Ann.Basco@sterlingadministration.com,Lola.Christensen@sterlingadministration.com,Duarte.Batista@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,accountrepresentative@sterlingadministration.com'; -- Added by Jaggi #11264
        ELSE
            L_TO_EMAIL_ID := 'jagadeesh.reddy@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,pooja.kc@sterlingadministration.com,vhsteam@sterlingadministration.com';
            L_CC_EMAIL_ID := 'raghavendra.joshi@sterlingadministration.com,Dhanya.Kumar@sterlingadministration.com';
        END IF;

    END IF;

    PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                    (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'  -- 'oracle@sterlinghsa.com'
                    ,P_TO_ADDRESS   => L_TO_EMAIL_ID
                    ,P_CC_ADDRESS   => L_CC_EMAIL_ID
                    ,P_SUBJECT      => l_subject_name
                    ,P_MESSAGE_BODY => L_HTML_MESSAGE
                    ,P_ACC_ID       => null
                    ,P_USER_ID      => 0
                    ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: send_uploadfile_notify', L_NOTIFICATION_ID  );

    update EMAIL_NOTIFICATIONS
    set    MAIL_STATUS = 'READY' 
    where  NOTIFICATION_ID  = L_NOTIFICATION_ID;

end SEND_UPLOADFILE_NOTIFY;



-----------------------Added by rprabu 7792 ----------------------Shedule A document upoad procedure... ------------------

Procedure UPLOAD_scheduleA_NOTIFY ( p_ben_plan_id   IN NUMBER,
                                    P_ACC_NUM       IN VARCHAR2,
                                    P_Entrp_id      IN  number ,
                                    P_notification_id OUT NUMBER )
is
    l_html_message      VARCHAR2(32000) ;
    l_notification_id   NUMBER;
    l_to_email_id       VARCHAR2(250);
    l_cc_email_id       VARCHAR2(250);
    l_file_names        VARCHAR2_TBL;
    l_file_list         VARCHAR2(2000);
  	L_Desc              VARCHAR2(250);
    L_To_Address        VARCHAR2(1000)  :=   NULL;    -----Ticket #8909 13/07/2020  size moved to 1000 from 250. by rprabu
    L_Cc_Address        VARCHAR2(1000)   := NULL;    -----Ticket #8909 13/07/2020 size moved to 1000 from 250. by rprabu
    l_subject_name      VARCHAR2(250);
    begin


    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: UPLOAD_scheduleA_NOTIFY file p_ben_plan_id', p_ben_plan_id  );

    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: UPLOAD_scheduleA_NOTIFY P_ACC_NUM', P_ACC_NUM  );

    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: UPLOAD_scheduleA_NOTIFY P_Entrp_id list', P_Entrp_id  );

     L_CC_ADDRESS :=  PC_CONTACT.GET_SALESREP_EMAIL(P_ENTRP_ID);
     -- Added by Joshi for 10974
     l_subject_name := 'Schedule A Document Uploaded for '||pc_entrp.get_entrp_name (P_Entrp_id) ||'('||pc_entrp.get_acc_num(P_Entrp_id) ||')' ;

     FOR K IN (SELECT PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(ENTRP_CODE,'-')) SUPER_ADMIN_EMAIL
                 FROM ENTERPRISE A
                WHERE ENTRP_ID  = P_ENTRP_ID )
     LOOP
               L_TO_ADDRESS :=  K.SUPER_ADMIN_EMAIL  ;
     END LOOP;


  ---  L_FILE_NAMES := ARRAY_FILL(P_FILE_NAMES,P_FILE_NAMES.count);

    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: UPLOAD_scheduleA_NOTIFY file list', L_FILE_NAMES.count  );

    IF   p_ben_plan_id IS NOT NULL THEN
     L_FILE_LIST := '<ul>';

       FOR j IN (SELECT DOCUMENT_NAME,  Description FROM File_Attachments
                  WHERE Entity_Id            = p_ben_plan_id
                    AND entity_name = 'BEN_PLAN_ENROLLMENT_SETUP'
               ORDER BY Attachment_Id DESC
       )
       LOOP
          L_FILE_LIST :=  L_FILE_LIST || '<li> ' ||  j.DOCUMENT_NAME  || ' </li>';
       EXIT;
       END LOOP;
     L_FILE_LIST := L_FILE_LIST ||'</ul>';

    L_HTML_MESSAGE  := 'Hello, </br> ' ;

       L_HTML_MESSAGE := L_HTML_MESSAGE || '<p>The below  Schedule A document(s)  is uploaded for the account  (' || P_ACC_NUM ||').</p>' ;  -- Added by Swamy for Ticket#7660
       -- Code ends for Ticket#7660.
       L_HTML_MESSAGE  := L_HTML_MESSAGE || L_FILE_LIST  ;
    else
        L_HTML_MESSAGE := L_HTML_MESSAGE || '<p>The below plan document(s) are uploaded for the Employer(' || P_ACC_NUM || ') to their plan. </p>' ;
        L_HTML_MESSAGE  := L_HTML_MESSAGE || L_FILE_LIST  ;
        L_HTML_MESSAGE  := L_HTML_MESSAGE || '<p> Please log in to SAM and navigate to the Service Documents module to view.</p> ';
    end if;

   -- IF  P_ACCOUNT_TYPE = 'FORM_5500'   THEN
          IF user = 'SAM' THEN
             L_TO_EMAIL_ID := Nvl( L_TO_ADDRESS, 'compliance@sterlingadministration.com')  ;
           --L_TO_EMAIL_ID := 'IT-team@sterlingadministration.com' ;
              L_CC_EMAIL_ID := 'IT-team@sterlingadministration.com,vhsteam@sterlingadministration.com';
         ELSE
               L_TO_EMAIL_ID := 'Cindy.Carrillo@sterlingadministration.com,bharaniguru.rajendiran@sterlingadministration.com,Rupesh.Aujikar@sterlingadministration.com,r.prabu@sterlingadministration.com' ;
               L_CC_EMAIL_ID := 'VHSQATeam@sterlingadministration.com,Srinivasulu.Gudur@sterlingadministration.com,Dhanya.Kumar@sterlingadministration.com';

        END IF;
 --   END IF;

    PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                    (P_FROM_ADDRESS => 'oracle@sterlinghsa.com'
                    ,P_TO_ADDRESS   => L_TO_EMAIL_ID
                    ,P_CC_ADDRESS   => Nvl(L_CC_ADDRESS,  L_CC_EMAIL_ID)
                    ,P_SUBJECT      => l_subject_name
                    ,P_MESSAGE_BODY => L_HTML_MESSAGE
                    ,P_ACC_ID       => null
                    ,P_USER_ID      => 0
                    ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

                    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: UPLOAD_scheduleA_NOTIFY', L_NOTIFICATION_ID  );

    P_notification_id := L_NOTIFICATION_ID;

    UPDATE email_notifications
       SET mail_status = 'READY'
     WHERE notification_id  = l_notification_id;

    PC_LOG.LOG_ERROR('PC_NOTIFICATIONS: UPLOAD_scheduleA_NOTIFY  sucess ', L_NOTIFICATION_ID  );

END UPLOAD_scheduleA_NOTIFY;

/** Invoice by Division Reports ***/
   PROCEDURE email_er_division_no_ees
   is

     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title> Employer Divisions ( with Invoice Setup) that has Zero Employees Assigned </title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p> If there are no employees assigned for the division , then we will not bill it properly make sure to verify that</p>
             </table>
              </body>
        </html>';
       L_Sql := 'SELECT NAME "Employer Name", RATE_PLAN_NAME "Rate Plan Name",
                        DIVISION_INVOICING "Division Invoicing"
                      , DIVISION_CODE "Division Code", DIVISION_NAME "Division Name",
                        EE_CNT "No of Employees"
                 FROM ( SELECT PC_ENTRP.GET_ENTRP_NAME(ENTITY_ID) NAME
                            , RATE_PLAN_NAME
                            , DIVISION_INVOICING
                            , A.DIVISION_CODE
                            , ED.DIVISION_NAME
                            , PC_EMPLOYER_DIVISIONS.GET_EMPLOYEE_COUNT(A.ENTITY_ID ,ED.DIVISION_CODE) EE_CNT
                      FROM rate_plans a, EMPLOYER_DIVISIONS ED
                      WHERE DIVISION_INVOICING = ''Y'' AND A.ENTITY_ID = ED.ENTRP_ID
                      AND   A.DIVISION_CODE = ED.DIVISION_CODE )
                  WHERE EE_CNT = 0';

      dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'IT-Team@sterlingadministration.com,VHSTeam@sterlingadministration.com'
                           ,'er_division_no_ees_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Employer Divisions with No Employees  ');
   END email_er_division_no_ees;
     PROCEDURE inactive_banks_invoice_setup
   is

     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title> Inactive Bank Accounts in Invoice Setups  </title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p> Inactive Banks in Invoice Setups </p>
             </table>
              </body>
        </html>';
       L_Sql := 'SELECT NAME "Employer Name", RATE_PLAN_NAME "Rate Plan Name",INVOICE_TYPE,BANK_NAME
                  FROM ( SELECT PC_ENTRP.GET_ENTRP_NAME(A.ENTITY_ID) NAME
                            , RATE_PLAN_NAME
                            , ED.INVOICE_TYPE
                            , U.BANK_NAME
                      FROM rate_plans a, INVOICE_PARAMETERS ED, USER_BANK_ACCT U
                      WHERE A.RATE_PLAN_ID =  ED.RATE_PLAN_ID
                      AND   ED.BANK_ACCT_ID = U.BANK_ACCT_ID
                      AND   U.STATUS = ''I'' and a.effective_end_date is null and ed.status = ''A'') ';

      dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'IT-Team@sterlingadministration.com,VHSTeam@sterlingadministration.com'
                           ,'invoice_with_inactive_bank'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Inactive Bank Accounts in Invoice Setups   ');
   END inactive_banks_invoice_setup;


   PROCEDURE email_division_rate_plan_setup (p_entrp_id IN NUMBER)
   is

     l_sql            VARCHAR2(32000);
     l_html_message   VARCHAR2(32000);
   BEGIN
       l_html_message  := '<html>
            <head>
                <title> Division Invoice Auto Setup for Employer  </title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p> Division Invoice Auto Setup for Employer,
                 Make sure to change the contact , bank account or any specific setup for the
                 specific division</p>
             </table>
              </body>
        </html>';
       L_Sql := 'SELECT PC_ENTRP.GET_ENTRP_NAME(ENTITY_ID) "Employer Name"
                      , RATE_PLAN_NAME "Rate Plan Name"
                      , DIVISION_INVOICING "Division Invoicing"
                      , DIVISION_CODE "Division Code"
                      , PC_EMPLOYER_DIVISIONS.GET_DIVISION_NAME(DIVISION_CODE, ENTITY_ID) "Division Name"
                FROM rate_plans WHERE ENTITY_ID = '||p_entrp_id ||
                ' AND TRUNC(CREATION_DATE) = TRUNC(SYSDATE) ';

      dbms_output.put_line('sql '||l_sql);
      Mail_Utility.Report_Emails('oracle@sterlingadministration.com'
                           ,'IT-Team@sterlingadministration.com,VHSTeam@sterlingadministration.com'
                           ,'division_invoice_rate_plans_'||p_entrp_id||'.xls'
                           , l_sql
                           , l_html_message
                           , ' Division Invoice Auto Setup for Employer  ');
   END email_division_rate_plan_setup;

   /** Invoice by Division Reports ***/

      /** Ticket#5027 ***/
   PROCEDURE renewal_email_notifications
 (p_account_type IN VARCHAR2
 ,p_user_id              IN NUMBER)
 IS
  l_message_body VARCHAR2(4000);
  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  num_tbl        number_tbl;
  l_cc_address  VARCHAR2(100);
  l_id  VARCHAR2(100) := 0;
  l_bkr_email VARCHAR2(4000) := 'VHSQATeam@sterlingadministration.com';
  l_broker_email VARCHAR2(4000);
  l_primary_email VARCHAR2(4000);

BEGIN

 /* For COBRA Accounts */
 IF P_ACCOUNT_TYPE = 'COBRA' THEN

   -- Added by Joshi for ticket 6589. Removed table contact/contact roles.
   FOR XX IN (  select  x.*
                  ,b.name
                  ,b.entrp_code
                  ,pc_contact.GET_SUPER_ADMIN_EMAIL(b.entrp_code) er_email
                  ,PC_broker.GET_BROKER_NAME(A.BROKER_ID)
                  ,pc_account.get_salesrep_name(a.am_id) SALESREP
                  ,PC_SALES_TEAM.get_salesrep_email(a.am_id) SALESREP_EMAIL
               from  account a
                   , table(pc_web_compliance.get_er_plans(a.acc_id, 'COBRA',null)) x
                   ,enterprise b

               where  /*not exists ( select * from ben_plan_renewals where acc_id = A.acc_id
                              and end_date > sysdate)*/
               a.account_type = 'COBRA'
               and   a.entrp_id=b.entrp_id
               and   b.State !='HI'
               and   a.account_status= 1
               and  a.end_date is null
               AND x.acc_id = A.ACC_id

	) LOOP

        SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'PRIMARY')));

		IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
        ELSE
               -- L_CC_ADDRESS :=  XX.salesrep_email;
                  L_CC_ADDRESS :=  'renewals@sterlingadministration.com';--Added by sk 08_12_2019
        END IF;


      IF l_primary_email IS NOT NULL THEN

		   /* commented for 7134 and moved above Joshi
           IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
           ELSE
                L_CC_ADDRESS :=  XX.salesrep_email;
           END IF; */

	         FOR X IN ( SELECT a.template_subject
                      ,  a.template_body
                      ,  a.cc_address
                  FROM   NOTIFICATION_TEMPLATE A
                  WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                  AND     TEMPLATE_NAME= 'RENEWAL_COBRA_ER_TEMPLATE'
                  AND     STATUS = 'A')
           LOOP

             PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
             (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
             ,P_TO_ADDRESS   => l_primary_email  --xx.er_email
             ,P_CC_ADDRESS   => L_CC_ADDRESS --'VHSQATeam@sterlingadministration.com'
             ,P_SUBJECT      => x.template_subject
             ,P_MESSAGE_BODY => x.template_body
             ,P_ACC_ID       => xx.acc_id
             ,P_USER_ID      => p_user_id
             ,X_NOTIFICATION_ID => l_notif_id );
             num_tbl(1):=p_user_id;
             add_notify_users(num_tbl,l_notif_id);

             l_acc_id := xx.acc_id;
                PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);


                 UPDATE EMAIL_NOTIFICATIONS
                 SET    MAIL_STATUS = 'READY'
                       ,   ACC_ID = l_acc_id
                        ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                 WHERE  NOTIFICATION_ID  = l_notif_id;
         END LOOP;

       END IF;

      /*Ticket#5507.For saounts,broker should no get multiple emails even though we have multiple users */
      -- IF xx.bkr_email IS NOT NULL AND l_id <> xx.acc_id THEN

      pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS  xx.acc_id: ', xx.acc_id);
      pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS l_broker_email: ',l_broker_email);

       IF  l_id <> xx.acc_id THEN

           l_id := xx.acc_id;
           pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS l_id:  ',l_id);

               FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_COBRA_BROKER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP
                   -- Added by Joshi for ticket 6589. Get contacts for BROKER from contact table.
                   FOR xxx IN (SELECT distinct email FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'BROKER')))
                   LOOP
                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => xxx.email
                     ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                       num_tbl(1):=p_user_id;
                       add_notify_users(num_tbl,l_notif_id);

                       l_acc_id := xx.acc_id;
                       PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                       PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                       PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);

                        UPDATE EMAIL_NOTIFICATIONS
                        SET    MAIL_STATUS = 'READY'
                            ,   ACC_ID = l_acc_id
                             ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                        WHERE  NOTIFICATION_ID  = l_notif_id;
                    END LOOP;
              END LOOP;
         END IF;
     END LOOP;/* Outer Loop COBAR Accounts */
 END IF; /* COBRA Accounts */

/* Added by Joshi for 12408 For POP Accounts */
 IF P_ACCOUNT_TYPE = 'POP' THEN


   FOR XX IN (  select  x.*
					  ,b.name
					  ,b.entrp_code
					  ,pc_contact.GET_SUPER_ADMIN_EMAIL(b.entrp_code) er_email
					  ,PC_broker.GET_BROKER_NAME(A.BROKER_ID)
					  ,pc_account.get_salesrep_name(a.am_id) SALESREP
					  ,PC_SALES_TEAM.get_salesrep_email(a.am_id) SALESREP_EMAIL
				   from  account a
					   , table(pc_web_compliance.get_er_plans(a.acc_id, 'POP',null)) x
					   ,enterprise b
				 where a.account_type = 'POP'
				   and   a.entrp_id=b.entrp_id
				   and   b.State !='HI'
				   and   a.account_status= 1
				   and  a.end_date is null
				   AND x.acc_id = A.ACC_id  )

	LOOP

        SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'PRIMARY')));

		IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
        ELSE
               -- L_CC_ADDRESS :=  XX.salesrep_email;
                  L_CC_ADDRESS :=  'renewals@sterlingadministration.com';
        END IF;


      IF l_primary_email IS NOT NULL THEN

	         FOR X IN ( SELECT a.template_subject
                      ,  a.template_body
                      ,  a.cc_address
                  FROM   NOTIFICATION_TEMPLATE A
                  WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                  AND     TEMPLATE_NAME= 'RENEWAL_POP_ER_TEMPLATE'
                  AND     STATUS = 'A')
           LOOP

             PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
             (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
             ,P_TO_ADDRESS   => l_primary_email  --xx.er_email
             ,P_CC_ADDRESS   => L_CC_ADDRESS --'VHSQATeam@sterlingadministration.com'
             ,P_SUBJECT      => x.template_subject
             ,P_MESSAGE_BODY => x.template_body
             ,P_ACC_ID       => xx.acc_id
             ,P_USER_ID      => p_user_id
             ,X_NOTIFICATION_ID => l_notif_id );
             num_tbl(1):=p_user_id;
             add_notify_users(num_tbl,l_notif_id);

             l_acc_id := xx.acc_id;
                PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);


                 UPDATE EMAIL_NOTIFICATIONS
                 SET    MAIL_STATUS = 'READY'
                       ,   ACC_ID = l_acc_id
                        ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                 WHERE  NOTIFICATION_ID  = l_notif_id;
         END LOOP;

       END IF;


      pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS  xx.acc_id: ', xx.acc_id);
      pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS l_broker_email: ',l_broker_email);

       IF  l_id <> xx.acc_id THEN

           l_id := xx.acc_id;
           pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS l_id:  ',l_id);

               FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_POP_BROKER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP
                   -- Added by Joshi for ticket 6589. Get contacts for BROKER from contact table.
                   FOR xxx IN (SELECT distinct email FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'BROKER')))
                   LOOP
                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => xxx.email
                     ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                       num_tbl(1):=p_user_id;
                       add_notify_users(num_tbl,l_notif_id);

                       l_acc_id := xx.acc_id;
                       PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                       PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                       PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                       PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);

                        UPDATE EMAIL_NOTIFICATIONS
                        SET    MAIL_STATUS = 'READY'
                            ,   ACC_ID = l_acc_id
                             ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                        WHERE  NOTIFICATION_ID  = l_notif_id;
                    END LOOP;
              END LOOP;
         END IF;
     END LOOP;/* Outer Loop POP Accounts */
 END IF; /* POP Accounts */


   /* Loop for FSA Accounts */
 IF P_ACCOUNT_TYPE = 'FSA' THEN
    FOR XX In ( select distinct acc_num, acc_id, name, entrp_code, BROKER_NAME,SALESREP,SALESREP_EMAIL
from (SELECT A.ACC_NUM
           ,A.ACC_ID
           ,C.NAME
           ,c.entrp_code
           ,PC_broker.GET_BROKER_NAME(A.BROKER_ID) BROKER_NAME
           ,pc_account.get_salesrep_name(a.am_id) SALESREP
         ,PC_SALES_TEAM.get_salesrep_email(a.am_id) SALESREP_EMAIL
            FROM 	ACCOUNT A,
                   BEN_PLAN_ENROLLMENT_SETUP B
                  ,ENTERPRISE C
           WHERE  A.ACC_ID                      = B.ACC_ID
           AND   c.ENTRP_ID                    = B.ENTRP_ID
           AND PRODUCT_TYPE                 = 'FSA'
           AND PLAN_TYPE NOT IN  ('TRN','PKG','UA1','IIR')
           AND ACCOUNT_STATUS                = 1
           AND STATUS                        = 'A'
           AND A.END_DATE IS NULL
           AND C.State !='HI'
           AND 'N'= (SELECT FLAG FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEWED_ALREADY(A.ACC_ID,PLAN_TYPE)))
           AND ( TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 90)
           OR  TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE-60) AND TRUNC(SYSDATE))
           AND NOT EXISTS (SELECT 1
                             FROM BEN_PLAN_ENROLLMENT_SETUP C
                            WHERE C.ACC_ID    = B.ACC_ID
                              AND C.PLAN_TYPE = B.PLAN_TYPE
                              AND C.PLAN_END_DATE > B.PLAN_END_DATE)
           AND NOT EXISTS (SELECT 1
                             FROM BEN_PLAN_DENIALS
                            WHERE BEN_PLAN_ID = B.BEN_PLAN_ID)
            --and a.acc_num in ('GFSA1122514','GFSA1122515')
       UNION -- Transit plans
         SELECT  A.ACC_NUM
              ,A.ACC_ID
             ,C.NAME
             ,c.entrp_code
             ,PC_broker.GET_BROKER_NAME(A.BROKER_ID) BROKER_NAME
             ,pc_account.get_salesrep_name(a.am_id) SALESREP
             ,PC_SALES_TEAM.get_salesrep_email(a.am_id) SALESREP_EMAIL
        FROM ACCOUNT A,
             BEN_PLAN_ENROLLMENT_SETUP B
            ,ENTERPRISE C
         WHERE A.ACC_ID                      = B.ACC_ID
        AND C.ENTRP_ID                    = B.ENTRP_ID
         AND PRODUCT_TYPE                 = 'FSA'
        AND PLAN_TYPE   IN  ('TRN','PKG','UA1')
        AND ACCOUNT_STATUS                = 1
        AND STATUS                        = 'A'
        AND A.END_DATE IS NULL
        AND C.State !='HI'
        --and a.acc_num in ('GFSA1122514','GFSA1122515')
        AND 'N'=  (SELECT FLAG FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEW_TRN_PKG  (A.ACC_ID,PLAN_TYPE)))
          /* commented by Joshi for 12003
        AND TO_DATE(TO_CHAR(PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR'),'DD-MON-RRRR')
                BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE+ 90)
        AND TO_DATE(TO_CHAR(PLAN_START_DATE,'DD-MON-YYYY'),'DD-MON-YYYY')  -- Added by swamy for Prod Issue mail 06Jan2023
               < TRUNC(SYSDATE-pc_web_er_renewal.G_PRIOR_DAYS) */
        -- Added by Joshi for ticket 12003  
        AND  pc_web_er_renewal.Get_plan_end_date_for_trn_pkg( A.ACC_ID, B.PLAN_TYPE)   BETWEEN 
        TRUNC(SYSDATE)- pc_web_er_renewal.G_AFTER_DAYS AND TRUNC(SYSDATE)+ pc_web_er_renewal.G_PRIOR_DAYS    
        AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_RENEWALS E
                          WHERE E.BEN_PLAN_ID = B.BEN_PLAN_ID
                           AND E.START_DATE  > pc_web_er_renewal.Get_plan_end_date_for_trn_pkg( A.ACC_ID, B.PLAN_TYPE)  -- Added by Swamy for Ticket#12120 15/04/2024
                           -- AND ((TO_CHAR(CREATION_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR'))
                             )
         AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_DENIALS
                          WHERE BEN_PLAN_ID = B.BEN_PLAN_ID)
          AND NOT EXISTS ( SELECT 1 FROM BEN_PLAN_ENROLLMENt_SETUP D    -- Not exists cond. Swamy 10526 02/11/2021
                                   WHERE   d.acc_id= b.acc_id AND PLAN_TYPE  NOT IN ('TRN','PKG','UA1')
                                   AND    D.STATUS = 'A'))

  )
   LOOP

        /* Broker Emails */
       IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
        ELSE
               -- L_CC_ADDRESS :=  XX.salesrep_email;
                  L_CC_ADDRESS :=  'renewals@sterlingadministration.com';
        END IF;

       -- Added by Joshi for ticket 6589(commented below line).
      --IF xx.bkr_email IS NOT NULL AND l_bkr_email <> xx.bkr_email AND l_id <> xx.acc_id THEN
       IF l_id <> xx.acc_id THEN
              l_id := xx.acc_id;

                   FOR X IN ( SELECT a.template_subject
                                ,  a.template_body
                                ,  a.cc_address
                            FROM   NOTIFICATION_TEMPLATE A
                            WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                            AND     TEMPLATE_NAME= 'RENEWAL_FSA_BROKER_TEMPLATE'
                            AND     STATUS = 'A')
                   LOOP
                        -- Added by Joshi for ticket 6589. Get contacts for BROKER from contact table.
                   FOR xxx IN (SELECT distinct email FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'BROKER')))
                   LOOP
                         PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                         (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                         ,P_TO_ADDRESS   => xxx.email -- xx.bkr_email -- commented by Joshi for ticket 6589
                         ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                         ,P_SUBJECT      => x.template_subject
                         ,P_MESSAGE_BODY => x.template_body
                         ,P_ACC_ID       => xx.acc_id
                         ,P_USER_ID      => p_user_id
                         ,X_NOTIFICATION_ID => l_notif_id );
                           num_tbl(1):=p_user_id;
                           add_notify_users(num_tbl,l_notif_id);

                           l_acc_id := xx.acc_id;
                           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);
                          -- PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',xx.PLAN_TYPE,l_notif_id);	 --Ticket#5755.Add Plan type to teh templates

                            UPDATE EMAIL_NOTIFICATIONS
                             SET    MAIL_STATUS = 'READY'
                                ,   ACC_ID = l_acc_id
                                ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                             WHERE  NOTIFICATION_ID  = l_notif_id;
                      END LOOP;
                  END LOOP;

         END IF;

           /* FSA ER Email */
        -- Added by Joshi for 6589. For ER email get primary contacts
        SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'PRIMARY')));

        --IF xx.er_email IS NOT NULL THEN
        IF l_primary_email IS NOT NULL THEN

               FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_FSA_ER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP

                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => l_primary_email  -- xx.er_email
                     ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                       num_tbl(1):=p_user_id;
                       add_notify_users(num_tbl,l_notif_id);

                       l_acc_id := xx.acc_id;
                        PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                        PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                        --PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                        PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);
                        --PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',xx.PLAN_TYPE,l_notif_id);	 --Ticket#5755.Add Plan type to teh templates


                         UPDATE EMAIL_NOTIFICATIONS
                         SET    MAIL_STATUS = 'READY'
                            ,   ACC_ID = l_acc_id
                            ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                         WHERE  NOTIFICATION_ID  = l_notif_id;
              END LOOP;
        END IF;
   END LOOP; /* End of FSA/HRA accounts */
  END IF ; /* End of FSA Accounts */


   /* HRA Accounts outer loop */
 IF P_ACCOUNT_TYPE = 'HRA' THEN
   FOR XX IN (SELECT DISTINCT    A.ACC_NUM
                ,A.ACC_ID
                ,C.NAME
                ,C.entrp_code
                , pc_contact.GET_SUPER_ADMIN_EMAIL(c.entrp_code) er_email
                ,PC_broker.GET_BROKER_NAME(A.BROKER_ID)
                ,pc_account.get_salesrep_name(a.am_id) SALESREP
                ,PC_SALES_TEAM.get_salesrep_email(a.am_id) SALESREP_EMAIL
            FROM   ACCOUNT A,
                BEN_PLAN_ENROLLMENT_SETUP B
                ,ENTERPRISE C
            WHERE   A.ACC_ID                      = B.ACC_ID
            AND C.ENTRP_ID                    = B.ENTRP_ID
            --and A.broker_id=p.pers_id
            AND NVL(SF_ORDINANCE_FLAG, 'N')  != 'Y'
            AND PRODUCT_TYPE                 = 'HRA'
            AND ACCOUNT_STATUS                = 1
            AND b.STATUS                        = 'A'
            AND A.END_DATE IS NULL
            AND C.State !='HI'
            AND 'N'= (SELECT FLAG FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEWED_ALREADY(A.ACC_ID,PLAN_TYPE)))
              AND ( TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 90)
              OR  TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE-60) AND TRUNC(SYSDATE))
            AND NOT EXISTS (SELECT 1
                                FROM DEDUCTIBLE_RULE
                               WHERE RULE_TYPE LIKE 'EMBED%'
                                 AND ENTRP_ID = A.ENTRP_ID
                                 AND PC_ACCOUNT.IS_STACKED_ACCOUNT (ENTRP_ID) = 'Y'
                                 AND PRODUCT_TYPE = 'HRA')
            AND NOT EXISTS (SELECT 1
                                FROM BEN_PLAN_RENEWALS E
                               WHERE E.BEN_PLAN_ID = B.BEN_PLAN_ID
                                 AND TO_CHAR(CREATION_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR'))
            AND NOT EXISTS (SELECT 1
                                FROM BEN_PLAN_DENIALS
                               WHERE BEN_PLAN_ID = B.BEN_PLAN_ID)
      )
    LOOP
          IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
          ELSE
              --  L_CC_ADDRESS :=  XX.salesrep_email;
                  L_CC_ADDRESS :=  'renewals@sterlingadministration.com';
          END IF;

       -- Added by Joshi for ticket 6589(commented below line).
      --IF xx.bkr_email IS NOT NULL AND l_bkr_email <> xx.bkr_email AND l_id <> xx.acc_id THEN
       IF l_id <> xx.acc_id THEN
          l_id := xx.acc_id;
          --l_bkr_email := l_broker_email ; -- xx.bkr_email;

               FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_HRA_BROKER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP
                   -- Added by Joshi for ticket 6589. Get contacts for BROKER from contact table.
                   FOR xxx in (SELECT distinct email FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'BROKER')))
                   LOOP
                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => xxx.email --l_broker_email -- xx.bkr_email
                     ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                       num_tbl(1):=p_user_id;
                       add_notify_users(num_tbl,l_notif_id);

                           l_acc_id := xx.acc_id;
                           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',xx.PLAN_TYPE,l_notif_id);	 --Ticket#5755.Add Plan type to teh templates

                           UPDATE EMAIL_NOTIFICATIONS
                           SET    MAIL_STATUS = 'READY'
                              ,   ACC_ID = l_acc_id
                              ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                           WHERE  NOTIFICATION_ID  = l_notif_id;
                    END LOOP;
              END LOOP;
         END IF;

         /* Employer HRA email */
        SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'PRIMARY')));

          -- IF xx.er_email IS NOT NULL THEN
          IF l_primary_email IS NOT NULL THEN

              FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_HRA_ER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP

                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => l_primary_email -- xx.er_email
                     ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                       num_tbl(1):=p_user_id;
                       add_notify_users(num_tbl,l_notif_id);

                       l_acc_id := xx.acc_id;
                           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',xx.PLAN_TYPE,l_notif_id);	 --Ticket#5755.Add Plan type to teh templates


                           UPDATE EMAIL_NOTIFICATIONS
                           SET    MAIL_STATUS = 'READY'
                              ,   ACC_ID = l_acc_id
                              ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                           WHERE  NOTIFICATION_ID  = l_notif_id;
              END LOOP;
         END IF;
    END LOOP ; /* END of HRA accounts */
 END IF; /* HRA Accounts */

   /* For ERISA Accounts */
 IF P_ACCOUNT_TYPE = 'ERISA_WRAP' THEN

   FOR XX IN (SELECT x.*
                   ,b.name
                   ,b.entrp_email er_email
                   ,b.entrp_code
                   ,PC_broker.GET_BROKER_NAME(A.BROKER_ID)
                   ,pc_account.get_salesrep_name(a.am_id) SALESREP
                   ,PC_SALES_TEAM.get_salesrep_email(a.am_id) SALESREP_EMAIL
               FROM  account a
                    , table(pc_web_compliance.get_er_plans(a.acc_id, 'ERISA_WRAP',null)) x
                    ,enterprise b
                    ,ben_plan_enrollment_setup L
            WHERE   x.ben_plan_id=L.ben_plan_id
              AND l.PLAN_END_DATE BETWEEN TRUNC(SYSDATE)- 60 AND  TRUNC(SYSDATE)+ 90
              AND a.account_type = 'ERISA_WRAP'
              AND B.State !='HI'
              AND a.entrp_id=b.entrp_id AND b.entrp_email is not null
              AND a.account_status=1 AND a.end_date is Null
)
  LOOP
         IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
         ELSE
                --L_CC_ADDRESS :=  XX.salesrep_email;
                  L_CC_ADDRESS :=  'renewals@sterlingadministration.com';
         END IF;



        -- Added by Joshi for ticket 6589(commented below line).
        --IF xx.bkr_email IS NOT NULL AND l_id <> xx.acc_id THEN
        IF l_id <> xx.acc_id THEN
          l_id := xx.acc_id;
          --l_bkr_email := l_broker_email ; -- xx.bkr_email;
             FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_ERISA_BROKER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP
                   -- Added by Joshi for ticket 6589. Get contacts for BROKER and PRIMARY contact type.
                  FOR XXX in ( SELECT Distinct email FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'BROKER')))
                    LOOP
                        PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                         (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                         ,P_TO_ADDRESS   => XXX.email -- l_bkr_email -- xx.bkr_email
                         ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                         ,P_SUBJECT      => x.template_subject
                         ,P_MESSAGE_BODY => x.template_body
                         ,P_ACC_ID       => xx.acc_id
                         ,P_USER_ID      => p_user_id
                         ,X_NOTIFICATION_ID => l_notif_id );
                           num_tbl(1):=p_user_id;
                           add_notify_users(num_tbl,l_notif_id);

                           l_acc_id := xx.acc_id;
                               PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                               PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                               PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                               PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);

                                UPDATE EMAIL_NOTIFICATIONS
                                 SET    MAIL_STATUS = 'READY'
                                    ,   ACC_ID = l_acc_id
                                    ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                                 WHERE  NOTIFICATION_ID  = l_notif_id;
                   END LOOP;
           END LOOP;
       END IF;

        /* Employer ERISA email */

        -- Added by Joshi for 6589.
        SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.entrp_code,'PRIMARY')));

        -- IF xx.er_email IS NOT NULL THEN
        IF l_primary_email IS NOT NULL THEN
              FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_ERISA_ER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP

                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => l_primary_email -- xx.er_email
                     ,P_CC_ADDRESS   => l_cc_address--'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                     num_tbl(1):=p_user_id;
                     add_notify_users(num_tbl,l_notif_id);

                       l_acc_id := xx.acc_id;
                           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('EXP_PLAN_YR',xx.plan_year,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('SALES_REP',xx.SALESREP,l_notif_id);

                            UPDATE EMAIL_NOTIFICATIONS
                             SET    MAIL_STATUS = 'READY'
                                ,   ACC_ID = l_acc_id
                                ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                             WHERE  NOTIFICATION_ID  = l_notif_id;
              END LOOP;
       END IF;
    END LOOP;/* End of ERISA accounts */
 END IF; /* End of ERISA accounts */



   /* For FORM5500 Accounts */
   -- start by swamy for email_blast
  IF P_ACCOUNT_TYPE = 'FORM_5500' THEN

    pc_log.log_error('RENEWAL_EMAIL_NOTIFICATION','P_ACCOUNT_TYPE: '||P_ACCOUNT_TYPE);

   FOR XX IN (SELECT x.*
				  ,x.entrp_name name
				 ,pc_contact.GET_SUPER_ADMIN_EMAIL(b.entrp_code) er_email --updated on 04/2/2020 to look at registered email
				  ,PC_broker.GET_BROKER_NAME(A.BROKER_ID)
				  ,pc_account.get_salesrep_name(x.am_id) SALESREP
				  ,PC_SALES_TEAM.get_salesrep_email(x.am_id) SALESREP_EMAIL
     			FROM  account a
				,table(pc_web_compliance.get_er_plans(a.acc_id, 'FORM_5500',null)) x
				,ben_plan_enrollment_setup L ,ENTERPRISE b
				WHERE   x.ben_plan_id=L.ben_plan_id
				--AND x.PLAN_END_DATE BETWEEN TRUNC(SYSDATE)- 60 AND  TRUNC(SYSDATE)+ 90
                AND   Trunc(SYSDATE)  BETWEEN Trunc( (x.plan_end_date) +30 ) AND Trunc(add_months( (x.plan_end_date),7) )
				and a.account_type = P_ACCOUNT_TYPE
				--AND x.entrp_email is not null   --commented on 04/2/2020 by sk
				AND a.account_status=1 AND a.end_date is Null
				and (L.renewal_flag is null or L.renewal_flag='N')
                and a.entrp_id=b.entrp_id
                --AND a.acc_num ='GF55636159'
)
  LOOP

         --l_subject :=  xx.plan_name || '-5500-(' || XX.plan_year ||')' ;
         IF USER NOT IN ('SAM','SHAVEE') THEN
                L_CC_ADDRESS := 'VHSQATeam@sterlingadministration.com';
         ELSE
              --  L_CC_ADDRESS :=  XX.salesrep_email;
                L_CC_ADDRESS :=  'renewals@sterlingadministration.com';
         END IF;

        pc_log.log_error('RENEWAL_EMAIL_NOTIFICATION','xx.acc_id'||xx.acc_id);

        -- Added by Joshi for ticket 6589(commented below line).
        IF l_id <> xx.acc_id THEN
          l_id := xx.acc_id;
          --l_bkr_email := l_broker_email ; -- xx.bkr_email;
             FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_FORM5500_BROKER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP
                   -- Added by Joshi for ticket 6589. Get contacts for BROKER and PRIMARY contact type.
                  FOR XXX in ( SELECT Distinct email FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.tax_id,'BROKER')))
                    LOOP

                        pc_log.log_error('RENEWAL_EMAIL_NOTIFICATION','XXX.email'||XXX.email);


                        PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                         (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                         ,P_TO_ADDRESS   => XXX.email -- l_bkr_email -- xx.bkr_email
                         ,P_CC_ADDRESS   => l_cc_address --'VHSQATeam@sterlingadministration.com'
                         ,P_SUBJECT      =>  x.template_subject --l_subject -- x.template_subject
                         ,P_MESSAGE_BODY => x.template_body
                         ,P_ACC_ID       => xx.acc_id
                         ,P_USER_ID      => p_user_id
                         ,X_NOTIFICATION_ID => l_notif_id );

                          pc_log.log_error('RENEWAL_EMAIL_NOTIFICATION','l_notif_id: '||l_notif_id);

                            num_tbl(1):=p_user_id;
                            add_notify_users(num_tbl,l_notif_id);

                           l_acc_id := xx.acc_id;
                           PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
						    PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER',xx.acc_num,l_notif_id);--SK Added on 04_08_2020 for Broker Template
                           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_NAME',xx.plan_name,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN('PLAN_NAME','SINGLE PLAN',l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_END_DATE',TO_CHAR(xx.PLAN_END_DATE,'MM/DD/YYYY'),l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('LAST_DATE',TO_CHAR(add_months(xx.PLAN_END_DATE,7),'MM/DD/YYYY'),l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('DUE_DATE',TO_CHAR(add_months(xx.PLAN_END_DATE,5),'MM/DD/YYYY'),l_notif_id);--SK Added on 04_07_2020


                           UPDATE EMAIL_NOTIFICATIONS
                              SET MAIL_STATUS = 'READY'
                                 ,ACC_ID = l_acc_id
                                 ,event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                           WHERE  NOTIFICATION_ID  = l_notif_id;
                   END LOOP;
           END LOOP;
       END IF;

        -- Employer ERISA email

        -- Added by Joshi for 6589.
        SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(XX.tax_id,NULL))
        WHERE ENTITY_TYPE IN ('PRIMARY','COMPLIANCE'));--Sk added to include primary and compliance 06/30/2020

        -- IF xx.er_email IS NOT NULL THEN
        IF l_primary_email IS NOT NULL THEN
              FOR X IN ( SELECT a.template_subject
                            ,  a.template_body
                            ,  a.cc_address
                        FROM   NOTIFICATION_TEMPLATE A
                        WHERE   NOTIFICATION_TYPE = 'EXTERNAL'
                        AND     TEMPLATE_NAME= 'RENEWAL_FORM5500_ER_TEMPLATE'
                        AND     STATUS = 'A')
               LOOP

                     PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                     (P_FROM_ADDRESS => 'Renewals@sterlingadministration.com'
                     ,P_TO_ADDRESS   => l_primary_email -- xx.er_email
                     ,P_CC_ADDRESS   => l_cc_address--'VHSQATeam@sterlingadministration.com'
                     ,P_SUBJECT      => x.template_subject
                     ,P_MESSAGE_BODY => x.template_body
                     ,P_ACC_ID       => xx.acc_id
                     ,P_USER_ID      => p_user_id
                     ,X_NOTIFICATION_ID => l_notif_id );
                     num_tbl(1):=p_user_id;
                     add_notify_users(num_tbl,l_notif_id);

                       l_acc_id := xx.acc_id;
                            PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',xx.name,l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_NAME',xx.plan_name,l_notif_id);
                           --PC_NOTIFICATIONS.SET_TOKEN('PLAN_NAME','SINGLE PLAN',l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('PLAN_END_DATE',TO_CHAR(xx.PLAN_END_DATE,'MM/DD/YYYY'),l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('LAST_DATE',TO_CHAR(add_months(xx.PLAN_END_DATE,7),'MM/DD/YYYY'),l_notif_id);
                           PC_NOTIFICATIONS.SET_TOKEN ('DUE_DATE',TO_CHAR(add_months(xx.PLAN_END_DATE,5),'MM/DD/YYYY'),l_notif_id);--SK Added on 04_07_2020


                            UPDATE EMAIL_NOTIFICATIONS
                             SET    MAIL_STATUS = 'READY'
                                ,   ACC_ID = l_acc_id
                                ,   event = 'RENEWAL_EMAIL_NOTIFICATIONS'
                             WHERE  NOTIFICATION_ID  = l_notif_id;
              END LOOP;
       END IF;

    END LOOP;-- End of ERISA accounts
 END IF; -- End of ERISA accounts


  EXCEPTION
  WHEN OTHERS THEN
    pc_log.log_error('ERROR..RENEWAL_EMAIL_NOTIFICATIONS ',SQLERRM);
END renewal_email_notifications;

PROCEDURE send_emails_Inv_not_generated
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN

--pc_log.log_error('Inv_not_generated started ...',l_sql);

    l_html_message  := '<html>
      <head>
          <title> Monthly fee invoice data not generated for the employers </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Monthly Fee Invoice Data Not Generated For Employers </p>
       </table>
        </body>
        </html>';


 l_sql := ' 	 Select Distinct A.Acc_Num,E.Name ,bp.ben_plan_name,  (plan_end_date+nvl(runout_period_days,0)+nvl(grace_period,0)) plan_Actual_End_date,
                  Bp.Plan_Start_Date,
                  Bp.Plan_End_Date,
				  Decode(Bp.Status,''I'', ''Inactive'', ''A'', ''Active'' , Bp.Status)   benefit_plan_Status,
                  rp.Effective_Date ,  rp.Effective_End_Date  ,
				  Decode(Rp.Status,''I'', ''Inactive'', ''A'', ''Active'' ,Rp.Status) rate_plan_Status
                 From Rate_Plans Rp , Account A , Enterprise E  , Ben_Plan_Enrollment_Setup Bp
        Where Rp.Entity_Type = ''EMPLOYER''
        And   Rate_Plan_Type = ''INVOICE''
        And  A.Entrp_Id = Rp.Entity_Id
        And  A.Account_Type In (''FSA'',''HRA'')
        And  A.Account_Status = 1
        And  RP.STATUS = ''A''
      	And  BP.STATUS = ''A''
	      And  E.Entrp_Id = A.Entrp_Id
        And  Bp.Acc_Id = A.Acc_Id
        And  Bp.Ben_Plan_Id_Main Is Null
        And plan_start_date   <= SYSDATE
        And (plan_end_date+nvl(runout_period_days,0)+nvl(grace_period,0)) >= SYSDATE
        And  Rp.Effective_Date <= TRUNC(SYSDATE,''MM'')
        And  Not Exists (Select 1  From Ar_Invoice
                         Where Rate_Plan_Id = Rp.Rate_Plan_Id
                         And Invoice_Reason = ''FEE''
                         And invoice_date > TRUNC(SYSDATE,''MM'')  )   ';


--pc_log.log_error('Inv_not_generated_1',l_sql);


   mail_utility.report_emails('oracle@sterlinghsa.com'
                           ,'Nabanita.Chakraborthy@sterlingadministration.com, '||
                           'Mallikarjun@sterlingadministration.com, '||
                           'Sumithra.Bai@sterlingadministration.com,'||
                           'IT-Team@sterlingadministration.com'
                           ,'MLY_FEE_INV_DATA_NOT_GENERATED_FOR_ER'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Employers Monthly Fee Invoice (Not Generated) for the Month of '||to_char(add_months(sysdate,-1) ,'MonthYYYY'));

--pc_log.log_error('Inv_not_generated_2',l_sql);

EXCEPTION
  WHEN OTHERS THEN
     NULL;
END send_emails_Inv_not_generated;

-- Added by Joshi for PPP.
PROCEDURE SEND_SCHEDULE_CONFIRM_EMAIL(p_ein IN NUMBER, p_acc_id IN NUMBER, p_user_id IN NUMBER)
AS
l_notify_id NUMBER;
l_email varchar2(2000);
l_account_type varchar2(50);
l_super_admin varchar2(250);
 BEGIN
 l_super_admin := pc_contact.GET_SUPER_ADMIN_EMAIL(p_ein);

 select account_type into l_account_type
 from  account
 where acc_id  =  p_acc_id ;


 FOR y IN (select  email from table(pc_contact.GET_PRIMARY_EMAIL( p_ein,l_account_type,'ENTERPRISE')))   -- ENTERPRISE Added by Swamy for Ticket#11087
   LOOP
   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
                AND  TEMPLATE_NAME = 'SCHEDULE_CONFIRM_NOTIFY'
                AND  STATUS = 'A')
   LOOP

        IF USER = 'SAM'  THEN
          IF  y.email IS NOT NULL THEN
               l_email :=  y.email || ',' || l_super_admin ;
          ELSE
               l_email :=  l_super_admin ;
          END IF;
        ELSE
           l_email := 'IT-team@sterlingadministration.com, Basavaraju.DM@sterlingadministration.com' ;
        END IF;

        IF l_email is not NULL THEN
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
           (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
           ,P_TO_ADDRESS   => l_email
           ,P_CC_ADDRESS   => x.cc_address
           ,P_SUBJECT      => x.template_subject
           ,P_MESSAGE_BODY => x.template_body
           ,P_USER_ID      => p_user_id
           ,P_ACC_ID       => p_acc_id
           ,X_NOTIFICATION_ID => l_notify_id );

            --pc_log.log_error('PC_NOTIFICATIONS.SEND_SCHEDULE_CONFIRM_EMAIL',l_notify_id);

           UPDATE EMAIL_NOTIFICATIONS
              SET    MAIL_STATUS = 'READY'
            WHERE  NOTIFICATION_ID  = l_notify_id;
        END IF;
    END LOOP;

   END LOOP;

    exception
       WHEN OTHERS THEN
-- Close the file if something goes wrong.

    pc_log.log_error('PC_NOTIFICATIONS.SEND_SCHEDULE_CONFIRM_EMAIL',sqlerrm);
END SEND_SCHEDULE_CONFIRM_EMAIL;


PROCEDURE SEND_SCHEDULER_REMIND_EMAIL
AS
l_notify_id NUMBER;
l_Subject varchar2(100);
l_email  varchar2(2000);
l_super_admin varchar2(250);
BEGIN

 FOR y IN (SELECT s.SCHEDULER_ID, s.recurring_frequency,  S.PLAN_TYPE,A.ACC_NUM , A.ACC_ID, E.NAME, E.ENTRP_CODE, A.ACCOUNT_TYPE,S.payment_start_date
           FROM SCHEDULER_MASTER S, ACCOUNT A, ENTERPRISE E
           WHERE S.ACC_ID = A.ACC_ID
                AND A.ENTRP_ID = E.ENTRP_ID
                AND S.SOURCE='ONLINE'
                AND NVL(S.STATUS, 'A') = 'A'
                AND (RECURRING_FLAG = 'Y'  AND EXISTS (SELECT * FROM scheduler_calendar WHERE SCHEDULE_ID = S.SCHEDULER_ID
                AND TRUNC(PERIOD_DATE) = TRUNC(SYSDATE+3))
                 OR ( RECURRING_FLAG = 'N' AND trunc(payment_start_date)  =  trunc(sysdate + 3)) ) )
   LOOP
		FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
                AND  TEMPLATE_NAME = 'DAILY_SCHEDULER_REMIND_EMAIL'
                AND  STATUS = 'A')
	   LOOP

			FOR e IN (select email from table(pc_contact.GET_PRIMARY_EMAIL(y.ENTRP_CODE,y.ACCOUNT_TYPE,'ENTERPRISE')))  -- ENTERPRISE Added by Swamy for Ticket#11087
			LOOP
				l_Subject := 'Your Upcoming ' ||  y.plan_type || ' contribution ';
                IF USER = 'SAM' THEN
                    IF e.email is not null THEN
                       l_email :=  e.email ;
                    END IF;
                    l_super_admin := pc_contact.GET_SUPER_ADMIN_EMAIL(y.ENTRP_CODE);
                    IF l_super_admin is not null THEN
                      IF l_email  is not null then
                         l_email :=  l_email || ',' || l_super_admin;
                      else
                         l_email := l_super_admin ;
                      end if;
                    END IF;

                ELSE
                   l_email := 'IT-team@sterlingadministration.com,Basavaraju.DM@sterlingadministration.com' ;
                END IF;

                 IF l_email is not NULL  then
                      PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                       (P_FROM_ADDRESS => 'customer.service@sterlingadministration.com'
                       ,P_TO_ADDRESS   => l_email
                       ,P_CC_ADDRESS   => x.cc_address
                       ,P_SUBJECT      => l_Subject
                       ,P_MESSAGE_BODY => x.template_body
                       ,P_USER_ID      => 0
                       ,P_ACC_ID       => y.acc_id
                       ,X_NOTIFICATION_ID => l_notify_id );

                        PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',y.acc_num,l_notify_id);
                        PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',y.plan_type,l_notify_id);
                        PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',y.name,l_notify_id);

                       UPDATE EMAIL_NOTIFICATIONS
                          SET    MAIL_STATUS = 'READY'
                        WHERE  NOTIFICATION_ID  = l_notify_id;
                    END IF;
			END LOOP;
		END LOOP;
    END LOOP;

END SEND_SCHEDULER_REMIND_EMAIL;

PROCEDURE DAILY_SCHEDULE_CONTRIB_REPORT
is
l_sql     VARCHAR2(32000);
l_email  varchar2(2000);
l_html_message varchar2(10);
begin

l_sql :=  'SELECT A.SCHEDULER_ID,
       CASE WHEN A.STATUS = ''D'' THEN ''DELETED''
              WHEN TRUNC(CREATION_DATE) = TRUNC(SYSDATE)  THEN ''NEW''
              ELSE ''UPDATE'' END Status,
       A.ACC_NUM,
       A.PLAN_TYPE,
       A.PAYMENT_METHOD,
       DECODE(A.RECURRING_FLAG ,''Y'',A.PERIOD_DATE,A.PAYMENT_START_DATE) FIRST_PAYMENT_DATE,
       A.PAYMENT_END_DATE,
       A.RECURRING_FLAG,
       A.RECURRING_FREQUENCY,
       A.AMOUNT  CONTRIBUTION_AMOUNT,
       A.FEE_AMOUNT CONTRIBUTION_FOR_FEES,
       NVL( A.AMOUNT, 0) + NVL(A.FEE_AMOUNT,0) TOTAL_CONTRIBUTION_AMOUNT,
       A.PAY_TO_ALL,
       A.NOTE
   FROM ( SELECT S.SCHEDULER_ID,S.RECURRING_FLAG, S.RECURRING_FREQUENCY,S.AMOUNT, S.FEE_AMOUNT, S.PAY_TO_ALL,S.NOTE, A.ACC_NUM, S.PLAN_TYPE, S.PAYMENT_METHOD, S.STATUS, SC.PERIOD_DATE, S.PAYMENT_START_DATE,
   S.PAYMENT_END_DATE,S.CREATION_DATE, DENSE_RANK() OVER (PARTITION BY S.SCHEDULER_ID ORDER BY SC.PERIOD_DATE) FIRST_PAYROLL_DATE
		FROM SCHEDULER_MASTER S, ACCOUNT A, SCHEDULER_CALENDAR SC
			WHERE S.ACC_ID = A.ACC_ID
            AND S.SOURCE IN ( ''ONLINE'', ''EDI'')
            AND ( TRUNC(S.CREATION_DATE) = TRUNC(SYSDATE-1) OR TRUNC(S.LAST_UPDATED_DATE) = TRUNC(SYSDATE-1))
            AND S.SCHEDULER_ID = SC.SCHEDULE_ID(+)
			AND ( (RECURRING_FLAG = ''Y'' AND EXISTS (SELECT * FROM SCHEDULER_CALENDAR WHERE SCHEDULE_ID = S.SCHEDULER_ID
			AND TRUNC(PERIOD_DATE) >= TRUNC(SYSDATE-1)))
			OR ( RECURRING_FLAG = ''N'' AND TRUNC(PAYMENT_START_DATE) >=  TRUNC(SYSDATE-1)))) A
 WHERE A.FIRST_PAYROLL_DATE = 1' ;

        IF USER = 'SAM' THEN
          l_email := 'ClientServicesFSA/HRA@sterlingadministration.com,VHSTeam@sterlingadministration.com,Sarah.Soman@sterlingadministration.com,IT-Team@sterlingadministration.com';

        ELSE
           l_email := 'IT-team@sterlingadministration.com,Basavaraju.DM@sterlingadministration.com' ;
		   --l_email := 'IT-team@sterlingadministration.com,Basavaraju.DM@sterlingadministration.com' ;
        END IF;
    --  dbms_output.put_line(l_sql) ;
    mail_utility.report_emails('oracle@sterlinghsa.com'
                           , l_email
                           ,'Daily_schedule_contrib_Report_'||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'Daily Report Payroll Contribution');

END DAILY_SCHEDULE_CONTRIB_REPORT;
/*Ticket#5020 POP Invoice report */

/*Ticket#5020 POP Invoice report */

PROCEDURE DAILY_ONLINE_RENEWAL_INV_POP IS
         L_UTL_ID               UTL_FILE.FILE_TYPE;
         L_FILE_NAME            VARCHAR2(3200);
         L_LINE                 LONG;
         L_FILE_ID              NUMBER;
         NO_POSTING             EXCEPTION;
         L_renewal_fee          NUMBER := 0;
         l_carrier_pay          NUMBER := 0;
         l_carrier_notif        NUMBER := 0;
         l_open_enrll_suite     NUMBER := 0;
         l_pay_method           VARCHAR2(255);
         l_email                VARCHAR2(3200);
         /*To Check if records exist*/
         l_data_exist          VARCHAr2(2) := 'N';
         l_count                number := 0;
         l_broker_notify       VARCHAr2(2) := 'N';
 BEGIN
               L_FILE_NAME := 'Daily_Online_Renewal_POP_Invoice_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.CSV';

              FOR X IN(SELECT A.NAME, B.ACC_NUM, B.BROKER_ID, B.GA_ID
                           --, PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) ACC_BROKER_NAME
                          --Ticket#4408.If Agenecy name is NULL then we display broker detail from ACCOUNT level
                           ,NVL((SELECT AGENCY_NAME
                           FROM EXTERNAL_SALES_TEAM_LEADS
                               WHERE ENTITY_TYPE = 'BROKER'
                                 and  entrp_id = a.entrp_id
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_RENEWALS' AND ROWNUM < 2), PC_BROKER.GET_BROKER_NAME(B.BROKER_ID)) BROKER_NAME
                          -- , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) ACC_GA_NAME
                           --Ticket#4408
                            ,NVL((SELECT AGENCY_NAME
                           FROM EXTERNAL_SALES_TEAM_LEADS
                               WHERE ENTITY_TYPE = 'GA'
                                 and  entrp_id = a.entrp_id
                                 AND REF_ENTITY_TYPE  = 'BEN_PLAN_RENEWALS' AND ROWNUM < 2),PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID)) GA_NAME
                           , TO_CHAR(ES.START_DATE,'mm/dd/rrrr')||','||TO_CHAR(ES.END_DATE,'mm/dd/rrrr') plandates
                           , PC_account.get_salesrep_name(B.SALESREP_ID) rep_name
                           , a.no_of_eligible
                           , A.ENTRP_ID
                           , ES.RENEWAL_BATCH_NUMBER
                           , ES.PAY_ACCT_FEES
                           , ES.RENEWED_PLAN_ID BEN_PLAN_ID
                           ,(SELECT BANK_NAME FROM USER_BANK_ACCT WHERE STATUS = 'A' and acc_id = b.acc_id AND  BANK_ACCT_ID = (SELECT MAX(BANK_ACCT_ID) FROM USER_BANK_ACCT WHERE ACC_ID = B.ACC_ID and STATUS = 'A'))BANK_NAME
                       FROM BEN_PLAN_RENEWALS ES, ENTERPRISE A,ACCOUNT B
                        WHERE ES.ACC_ID = B.ACC_ID
                       AND   A.ENTRP_ID = B.ENTRP_ID
                       AND   ES.PLAN_TYPE IN('BASIC_POP','COMP_POP')
                       AND   B.ACCOUNT_TYPE = 'POP'
                       AND TRUNC(ES.CREATION_DATE)>= TRUNC(SYSDATE-1))
              LOOP
                  /* We create a file only if data exist */
                   IF l_data_exist = 'N' THEN
                        L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );
                        L_LINE := 'Employer Name,Account Number,Product,Broker Name, GA, Sales rep,Start date,End Date,'
                            ||'Total Eligible Employees,Renewal Amount,'
                            ||'Bank Name,Payment Method,'
  	                        ||'Send Invoice to Broker/GA, Broker/GA emails for Invoice ?,Who will be responsible for paying POP account fee ? ';

                           UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                  BUFFER => L_LINE );
                   END IF;
                    l_count := l_count+1;
                    L_renewal_fee           := 0;
                 --   l_carrier_pay           := 0;
                  --  l_carrier_notif         := 0;
                  --  l_open_enrll_suite      := 0;
                    l_data_exist            := 'Y';

                    L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||',POP,'||'"'||X.BROKER_NAME||'","'||X.GA_NAME||'","'||x.rep_name||'",'
                            ||X.plandates||','||x.no_of_eligible;

                     FOR I IN (SELECT  total_quote_price price
                                       ,payment_method
                               FROM  AR_QUOTE_HEADERS B
                                WHERE B.BEN_PLAN_ID = X.BEN_PLAN_ID
                                AND   B.ENTRP_ID = X.ENTRP_ID )
                     LOOP
                          L_renewal_fee   := i.PRICE;
                          l_pay_method := i.payment_method;
                     END LOOP;
                      L_LINE := l_line ||','||NVL(L_renewal_fee,0)||','||X.bank_name||','||l_pay_method;
                      l_broker_notify := 'N' ;
                      FOR xX IN ( SELECT  --- WM_CONCAT(EMAIL) EMAIL , --- Commented by RPRABU 0n 17/10/2017
                                  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL) EMAIL ,  -- Added by RPRABU 0n 17/10/2017
                                  DECODE(SEND_INVOICE,1,'Yes','No')SEND_INVOICE FROM CONTACT_LEADS
  		                           --WHERE REF_ENTITY_ID=  X.RENEWAL_BATCH_NUMBER
                                 WHERE ENTITY_ID = PC_ENTRP.GET_TAX_ID(X.ENTRP_ID) --Ticket#4408
  		                          	AND   REF_ENTITY_TYPE in('BEN_PLAN_RENEWALS','ENTERPRISE','ONLINE_ENROLLMENT')
  		               	          	AND   SEND_INVOICE = '1'
                                  GROUP BY SEND_INVOICE)
                      LOOP

                          L_LINE := l_line ||','||xx.send_invoice||',"'||xx.email||'"';                      --L_LINE := l_line ||',Yes,"'||xx.email||'"';
                          l_broker_notify := 'Y';
  		                END LOOP;

                      IF l_broker_notify = 'N' THEN
                          L_LINE := l_line ||','||''||','||'';
                      END IF;
                      L_LINE := l_line ||','||x.PAY_ACCT_FEES; --- added this for renewal phase 2
                     UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                  BUFFER => L_LINE );
              END LOOP;

              UTL_FILE.FCLOSE(FILE => L_UTL_ID);
            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'  AND l_count > 0 THEN
                 IF USER = 'SAM' THEN
                   l_email :=  'compliance@sterlingadministration.com,VHSTeam@sterlingadministration.com'||
                               ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com'||
                               ',IT-team@sterlingadministration.com';

                 ELSE
                   l_email :=  'IT-team@sterlingadministration.com';

                 END IF;
                  mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlinghsa.com'
                                                ,  p_to_email  => l_email
                                                ,  p_file_name => l_file_name
                                                ,  p_sql       => null
                                                ,  p_html_message => null
                                                ,  p_report_title => 'POP  Online Renewal Invoice Report for  '||to_char(sysdate,'MM/DD/YYYY'));

              END IF;



      EXCEPTION
           WHEN NO_POSTING THEN
                NULL;
           WHEN OTHERS THEN
                raise;
END DAILY_ONLINE_RENEWAL_INV_POP;

-- Added by Joshi for 6796. confirmation email for outside investment.
PROCEDURE SEND_AMERITRADE_CONFIRM_EMAIL(p_acc_id IN NUMBER, p_user_id IN NUMBER)
AS
l_notify_id NUMBER;
l_email varchar2(2000);
l_name     VARCHAR2(100);
l_owner varchar2(50);
 BEGIN

   FOR X IN ( SELECT a.template_subject
                  ,  a.template_body
                  ,  a.to_address
                  ,  a.cc_address
              FROM   NOTIFICATION_TEMPLATE A
              WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
                AND  TEMPLATE_NAME = 'OUTISIDE_INVEST_CONFIRM'
                AND  STATUS = 'A')
   LOOP

        l_name := pc_person.get_person_name(pc_person.pers_id_from_acc_id(p_acc_id));

        -- get the owner as this is called from apex.
        select distinct(owner) into l_owner from apex_applications where application_id = 204 and ROWNUM = 1;

       -- pc_log.log_error('PC_NOTIFICATIONS.SEND_SCHEDULE_CONFIRM_EMAIL user from apex ',l_owner);
        --pc_log.log_error('PC_NOTIFICATIONS.SEND_SCHEDULE_CONFIRM_EMAIL user ',user);

        IF l_owner = 'SAM'  THEN
            l_email :=  pc_users.get_email(NULL,P_ACC_ID,NULL);
        ELSE
            --l_email :=  pc_users.get_email(NULL,P_ACC_ID,NULL);
            l_email := 'IT-team@sterlingadministration.com, Basavaraju.DM@sterlingadministration.com' ;
        END IF;

        IF l_email is not NULL THEN
                PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
               (P_FROM_ADDRESS      => 'customer.service@sterlingadministration.com'
               ,P_TO_ADDRESS        => l_email
               ,P_CC_ADDRESS        => x.cc_address
               ,P_SUBJECT           => x.template_subject
               ,P_MESSAGE_BODY      => x.template_body
               ,P_USER_ID           => p_user_id
               ,P_ACC_ID            => p_acc_id
               ,P_TEMPLATE_NAME     => 'OUTISIDE_INVEST_CONFIRM'
               ,X_NOTIFICATION_ID   => l_notify_id );

           PC_NOTIFICATIONS.SET_TOKEN ('subscriber_name',l_name,l_notify_id);

           UPDATE EMAIL_NOTIFICATIONS
              SET    MAIL_STATUS = 'READY'
            WHERE  NOTIFICATION_ID  = l_notify_id;
        END IF;
    END LOOP;

    exception
       WHEN OTHERS THEN
-- Close the file if something goes wrong.

    pc_log.log_error('PC_NOTIFICATIONS.SEND_SCHEDULE_CONFIRM_EMAIL',sqlerrm);
END SEND_AMERITRADE_CONFIRM_EMAIL;

PROCEDURE SEND_FINANCE_AMERITRADE_REQ(P_ACC_NUM VARCHAR2,P_CLAIM_NUMBER NUMBER, P_CLAIM_AMOUNT IN NUMBER)
IS
l_notify_id NUMBER;
l_email varchar2(2000);
BEGIN
 FOR X IN ( SELECT a.template_subject
                  ,a.template_body
                  ,a.to_address
                  ,a.cc_address
             FROM  NOTIFICATION_TEMPLATE A
            WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
              AND  TEMPLATE_NAME = 'OUTSIDE_FINANCE_CONFIRM'
              AND  STATUS = 'A')
   LOOP


        IF USER = 'SAM'  THEN
            l_email :=  'finance.department@sterlinghsa.com' ;
        ELSE
            l_email := 'IT-team@sterlingadministration.com, Basavaraju.DM@sterlingadministration.com' ;
        END IF;

        IF l_email is not NULL THEN
                PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
               (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
               ,P_TO_ADDRESS      => l_email
               ,P_CC_ADDRESS      => x.cc_address
               ,P_SUBJECT         => x.template_subject
               ,P_MESSAGE_BODY    => x.template_body
               ,P_USER_ID         => 0
               ,P_ACC_ID          => NULL
               ,P_TEMPLATE_NAME   => 'OUTSIDE_FINANCE_CONFIRM'
               ,X_NOTIFICATION_ID => l_notify_id );

           PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,l_notify_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_NUMBER',P_CLAIM_NUMBER,l_notify_id);
           PC_NOTIFICATIONS.SET_TOKEN ('CLAIM_AMOUNT', FORMAT_MONEY(p_claim_amount),l_notify_id);

           UPDATE EMAIL_NOTIFICATIONS
              SET    MAIL_STATUS = 'READY'
            WHERE  NOTIFICATION_ID  = l_notify_id;
        END IF;
    END LOOP;

    exception
       WHEN OTHERS THEN
-- Close the file if something goes wrong.

    pc_log.log_error('PC_NOTIFICATIONS.SEND_SCHEDULE_CONFIRM_EMAIL',sqlerrm);

END SEND_FINANCE_AMERITRADE_REQ ;

-- Below Procedure is Added by Swamy for Nacha Ticket#7723
-- Procedure is used to Send mail regarding the Nacha records
PROCEDURE Notify_nacha_result(P_Account_Type  IN VARCHAR2
                             ,P_FILE_NAME     IN VARCHAR2
                              ) 
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);
  l_email          VARCHAR2(2000);

BEGIN
  pc_log.log_error('PC_NOTIFICATIONS.Notify_nacha_result Begin','');

    l_html_message  := '<html>
      <head>
          <title>CNB - Sterling Transactions for </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>CNB - Sterling Transactions   </p>
       </table>
        </body>
        </html>';

   pc_log.log_error('PC_NOTIFICATIONS.Notify_nacha_result Begin',' USER := '||USER);

    --IF USER = 'SAM' THEN
       l_email := 'Corp.Finance@sterlingadministration.com'||',IT-team@sterlingadministration.com'||',finance.department@sterlinghsa.com';
    --ELSE
    --   l_email := 'IT-team@sterlingadministration.com';
    --END IF;

    IF NVL(P_Account_Type,'N') = 'N' THEN
        l_sql := 'SELECT D.ACC_NUM ACCOUNT_NUMBER,D.FIRST_NAME,D.LAST_NAME,A.TRANSACTION_ID,D.ACCOUNT_TYPE,D.AMOUNT TRANSACTION_AMOUNT , D.TRANSACTION_TYPE
                    FROM ACH_TRANSFER A , NACHA_PROCESS_LOG D
                   WHERE A.TRANSACTION_ID = D.TRANSACTION_ID
                     AND D.FLG_PROCESSED = ''N''
                     AND NVL(D.TRANSACTION_TYPE,''N'') = ''F''
                     AND NVL(D.file_name,''N'') = NVL('''||P_file_name||''',''N'')';
           pc_log.log_error('PC_NOTIFICATIONS.Notify_nacha_result calling mail_utility.report_emails 1 ',' l_sql := '||l_sql);
     mail_utility.report_emails('oracle@sterlinghsa.com'
                           --,'Corp.Finance@sterlingadministration.com'||',IT-team@sterlingadministration.com'||',finance.department@sterlinghsa.com'
                           ,l_email
                           ,'CNB ('||P_FILE_NAME||') - Sterling (FEE) Transactions for '||to_char(sysdate,'MMDDYYYY')||'.xls'
                           , l_sql
                           , l_html_message
                           , 'CNB ('||P_FILE_NAME||') - Sterling (FEE) Transactions for '||to_char(sysdate,'MM/DD/YYYY'));

    ELSE
        -- Added below by Joshi for 12748
        IF UPPER(P_FILE_NAME) like '%PAYMENT%' THEN

            l_sql := 'SELECT D.ACC_NUM ACCOUNT_NUMBER,D.FIRST_NAME,D.LAST_NAME,A.TRANSACTION_ID,D.ACCOUNT_TYPE,D.AMOUNT TRANSACTION_AMOUNT , D.TRANSACTION_TYPE
                        FROM ACH_TRANSFER A , NACHA_PROCESS_LOG D
                       WHERE A.TRANSACTION_ID = D.TRANSACTION_ID
                         AND D.FLG_PROCESSED = ''N''
                         AND NVL(D.TRANSACTION_TYPE,''N'') = ''P''
                         AND NVL(D.ACCOUNT_TYPE,''N'') = NVL('''||P_ACCOUNT_TYPE||''',''N'')
                         AND NVL(D.file_name,''N'') = NVL('''||P_file_name||''',''N'')';

            pc_log.log_error('PC_NOTIFICATIONS.Notify_nacha_result calling mail_utility.report_emails 2 ',' l_sql := '||l_sql);
            mail_utility.report_emails('oracle@sterlinghsa.com'
                                --,'Corp.Finance@sterlingadministration.com'||',IT-team@sterlingadministration.com'||',finance.department@sterlinghsa.com'
                                ,l_email
                                ,'CNB ('||P_FILE_NAME||') - Sterling ('||P_Account_Type||') Payment Transactions for '||to_char(sysdate,'MMDDYYYY')||'.xls'
                               , l_sql
                               , l_html_message
                               , 'CNB ('||P_FILE_NAME||') - Sterling ('||P_Account_Type||') Payment Transactions for '||to_char(sysdate,'MM/DD/YYYY'));
        ELSE
            l_sql := 'SELECT D.ACC_NUM ACCOUNT_NUMBER,D.FIRST_NAME,D.LAST_NAME,A.TRANSACTION_ID,D.ACCOUNT_TYPE,D.AMOUNT TRANSACTION_AMOUNT , D.TRANSACTION_TYPE
                            FROM ACH_TRANSFER A , NACHA_PROCESS_LOG D
                           WHERE A.TRANSACTION_ID = D.TRANSACTION_ID
                             AND D.FLG_PROCESSED = ''N''
                             AND NVL(D.TRANSACTION_TYPE,''N'') NOT IN (  ''F'',''P'')
                             AND NVL(D.ACCOUNT_TYPE,''N'') = NVL('''||P_ACCOUNT_TYPE||''',''N'')
                             AND NVL(D.file_name,''N'') = NVL('''||P_file_name||''',''N'')';

                pc_log.log_error('PC_NOTIFICATIONS.Notify_nacha_result calling mail_utility.report_emails 2 ',' l_sql := '||l_sql);
                mail_utility.report_emails('oracle@sterlinghsa.com'
                                    --,'Corp.Finance@sterlingadministration.com'||',IT-team@sterlingadministration.com'||',finance.department@sterlinghsa.com'
                                    ,l_email
                                    ,'CNB ('||P_FILE_NAME||') - Sterling ('||P_Account_Type||') Transactions for '||to_char(sysdate,'MMDDYYYY')||'.xls'
                                   , l_sql
                                   , l_html_message
                                   , 'CNB ('||P_FILE_NAME||') - Sterling ('||P_Account_Type||') Transactions for '||to_char(sysdate,'MM/DD/YYYY'));
        END IF;

    END IF;


EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('error message '||SQLERRM);
    pc_log.log_error('PC_NOTIFICATIONS.Notify_nacha_result Others',SQLERRM);
end Notify_nacha_result;


 --  Ticket #7856 Added by rprabu for form_5500 invoice renewal report
     PROCEDURE DAILY_ONLINE_RWL_INV_FORM_5500 IS
       L_UTL_ID               UTL_FILE.FILE_TYPE;
       L_FILE_NAME            VARCHAR2(3200);
       L_LINE                 LONG;
       L_FILE_ID              NUMBER;
       NO_POSTING             EXCEPTION;
       L_renewal_fee          NUMBER := 0;
       l_carrier_pay          NUMBER := 0;
       l_carrier_notif        NUMBER := 0;
       l_open_enrll_suite     NUMBER := 0;
       l_pay_method           VARCHAR2(255);
       l_email                VARCHAR2(3200);
       l_count                number := 0;
       l_broker_notify        VARCHAR2(1) := 'N';
   BEGIN
             L_FILE_NAME := 'Daily_Online_Renewal_FORM_5500_'||TO_CHAR(SYSDATE,'YYYYMMDD_HH24_MI')||'.CSV';

             L_LINE := null;

            L_UTL_ID := UTL_FILE.FOPEN( 'MAILER_DIR', L_FILE_NAME, 'W' );
            ----Benefit Plan Name ,
            L_LINE := 'Employer Name,Account Number, Product,Benefit Plan Name ,Broker Name,General Agent, Sales representative ,Start date,End Date,'
            ||'Total Eligible Employees,Renewal Amount,'
            ||'Bank Name,Payment Method, '
	          ||'Send Invoice to Broker/GA, Broker/GA emails for Invoice ?, '
            ||'Who will be responsible for paying FORM 5500 account fee'; --- added this for renewal phase 2


            UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                                               BUFFER => L_LINE );

             FOR X IN (SELECT A.NAME, B.ACC_NUM
                          , C.ben_Plan_Name, C.Ben_Plan_Number   ---  --- Ticket #8538
                         , B.BROKER_ID, B.GA_ID
                         , PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) BROKER_NAME
                         , PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) GA_NAME
                         , TO_CHAR(ES.START_DATE,'mm/dd/rrrr')||','||TO_CHAR(ES.END_DATE,'mm/dd/rrrr') plandates
                         , PC_account.get_salesrep_name(B.SALESREP_ID) rep_name
                         , a.no_of_eligible
                         , A.ENTRP_ID
                         ,  ES.BEN_PLAN_ID   RENEWED_PLAN_ID  --- ES.BEN_PLAN_ID added here
                         , ES.PAY_ACCT_FEES --- added this for renewal phase 2
                         , (select  max(bank_name)   FROM user_bank_acct     where acc_id=  b.acc_id) bank_name  -- 8524 prabu  -- 8524 prabu
                     FROM BEN_PLAN_RENEWALS ES, ENTERPRISE A,ACCOUNT B,  BEN_PLAN_ENROLLMENT_SETUP C
                    WHERE ES.ACC_ID = B.ACC_ID
                     AND   A.ENTRP_ID = B.ENTRP_ID
                    AND B.ACC_ID = C.ACC_ID      ----7856
                      AND ES.BEN_PLAN_ID = C.BEN_PLAN_ID    ----7856
                      AND   B.ACCOUNT_TYPE = 'FORM_5500'
                     AND TRUNC(ES.CREATION_DATE)>= TRUNC(SYSDATE-1)
                      Order by C.ben_Plan_Name   )
          LOOP
                 l_count                          := l_count+1;
                  L_renewal_fee           :=  0;


                   L_LINE := '"'||X.NAME||'",'||X.ACC_NUM||',Form 5500,'||'"'||X.ben_Plan_Name||'","'||X.BROKER_NAME||'","'||X.GA_NAME||'","'||x.rep_name||'",'
                          ||X.plandates||','||x.no_of_eligible;

        ---    dbms_output.put_line('L_LINE 1 : '||L_LINE );
                For I In (Select       ----  C.Line_List_Price Price
                       Sum(C.Line_List_Price) Over (Partition By     B.Ben_Plan_Id )   Price   --- Ticket #8538
                                     ,Rpd.Coverage_Type
                                     ,Payment_Method
				                            ,Decode(B.Payment_Method,'Check',Null, Pc_User_Bank_Acct.Get_Bank_Name(B.Bank_Acct_Id)) Bank_Name
                             From  AR_Quote_Headers B, AR_Quote_Lines C,
                                        Rate_Plan_Detail Rpd
                             Where  C.Rate_Plan_Detail_Id  =   Rpd.Rate_Plan_Detail_Id
                             And    B.Quote_Header_Id          =   C.Quote_Header_Id
                             And    B.Ben_Plan_Id                    =   X.Renewed_Plan_Id
                             And B.Ben_Plan_Number            =   X.Ben_Plan_Number  --- Ticket #8538
                             And   B.Entrp_Id                            =    X.Entrp_Id
                         		Order By B.Quote_Header_Id	Desc )  --- Ticket #8538
                  LOOP
                         L_renewal_fee   := i.PRICE;
                         l_pay_method := i.payment_method;
                         L_LINE := l_line ||','||NVL( i.PRICE,0)||','||
                                     X.bank_name||','||i.payment_method;
                                      exit ;--- Ticket #8538

		   END LOOP;
       l_broker_notify := 'N';
            ---------    Ticket #8524 added by rprabu
         FOR xX IN   (Select    decode(max(send_invoice), 1, ' Yes', 'No')  send_invoice ,   LISTAGG(email, ', ') WITHIN GROUP (ORDER BY entity_id  ) email    from contact_leads
                           WHERE entity_id  = PC_ENTRP.GET_TAX_ID(X.ENTRP_ID)
                              AND Account_Type = 'FORM_5500'
                               and contact_type in ('BROKER', 'GA')
                               and lic_number is null  )
                    LOOP
                        L_LINE := l_line ||','||xx.send_invoice||',"'||xx.email||'"';
                        l_broker_notify := 'Y';
		                END LOOP;
              ---      dbms_output.put_line('L_LINE 2 : '||L_LINE );
       IF l_broker_notify = 'N' THEN
                        L_LINE := l_line ||',   ,';
               END IF;
                    L_LINE := l_line ||','|| initcap(X.PAY_ACCT_FEES); --- added this for renewal phase 2


                    dbms_output.put_line('L_LINE 2 : '||L_LINE );
                 UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,   BUFFER => L_LINE );

            END LOOP;
             --       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,
                 ---               BUFFER => L_LINE );

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);
         ----   dbms_output.put_line('L_LINE 3 : '||L_LINE );

            IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE'
               AND l_count > 0 THEN

               IF USER = 'SAM' THEN
						l_email :=  'compliance@sterlingadministration.com,VHSTeam@sterlingadministration.com'||
						 ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com,IT-team@sterlingadministration.com';
                                  ---       l_email :=  'IT-Team@sterlingadministration.com';
               ELSE
                                        l_email :=  'IT-Team@sterlinghsa.com';
             END IF;

                mail_utility.send_file_in_emails(p_from_email =>  'oracle@sterlinghsa.com'
                                              ,  p_to_email  => l_email
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'Form 5500  Online Renewal Invoice Report for '||to_char(sysdate,'MM/DD/YYYY'));

            END IF;
  EXCEPTION    WHEN NO_POSTING THEN
            pc_log.log_error('PC_NOTIFICATIONS.DAILY_ONLINE_RWL_INV_FORM_5500 1: ',sqlerrm);
         WHEN OTHERS THEN
          pc_log.log_error('PC_NOTIFICATIONS.DAILY_ONLINE_RWL_INV_FORM_5500 2 : ',sqlerrm);
           raise;
   END DAILY_ONLINE_RWL_INV_FORM_5500;



   --  Ticket #8683  Added by rprabu for  FSA rollover notification
 PROCEDURE Notify_Rollover(P_acc_id IN  Number,
                                                             P_Rollover_Amount NUmber ,
                                                             p_Plan_type IN varchar2)
IS

  l_notif_id     NUMBER;
  l_acc_id       NUMBER;
  l_cc_address   VARCHAR2(255);
  l_template_subject VARCHAR2(4000);
  l_template_body  VARCHAR2(32000);
  l_to_address   VARCHAR2(255);
  l_employee_name VARCHAR2(255);
  l_email  VARCHAR2(255);


BEGIN

     pc_log.log_error('PC_CLAIM.Notify_Rollover','P_Rollover_Amount  '||P_Rollover_Amount );
    Get_template_body('NOTIFY_ROLLOVER',l_template_subject,l_template_body,l_cc_address,l_to_address);

    l_email := Null;
	  Begin
			   Select   first_name ||  '  ' || Last_name , email
			   Into     l_employee_name , l_email
			   From account A, Person B
			   Where   A.pers_id =b.pers_id
					 And a. entrp_id is null
					 And a.account_status =1
					 And  a.Acc_id =P_acc_id;

	Exception when  NO_DATA_FOUND Then
	   Null ;
	End;

  If l_email Is Not NUll Then

      l_template_subject  := 'Your ' ||   p_Plan_type   || ' Rollover Has Been Processed';

                 PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                (P_FROM_ADDRESS => 'Benefits@Sterlingadministration.com'
                ,P_TO_ADDRESS   =>   l_email
                ,P_CC_ADDRESS   =>  'Benefits@Sterlingadministration.com'  -- l_cc_address added by Joshi as suggested by Shavee 29/12/2021
                ,P_SUBJECT      =>  l_template_subject
               ,P_MESSAGE_BODY  => l_template_body
                ,P_ACC_ID       => P_acc_id
                ,P_USER_ID      => 0
                ,X_NOTIFICATION_ID => l_notif_id );


                 PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNTHOLDER_NAME',   l_employee_name ,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE', p_Plan_type ,l_notif_id);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_AMOUNT', P_Rollover_Amount ,l_notif_id);


                 UPDATE EMAIL_NOTIFICATIONS

                 SET    MAIL_STATUS = 'OPEN', Event =  'ROLLOVER_NOTIFY_EVENT'
                 WHERE  NOTIFICATION_ID  = l_notif_id;

     pc_log.log_error('PC_CLAIM.Notify_Rollover','l_notif_id '||l_notif_id );

   End If;

   Exception    WHEN OTHERS THEN
     pc_log.log_error('PC_CLAIM.Notify_Rollover','error message  :  '||SQLERRM );
	 Rollback;
END Notify_Rollover;

--- Ticket 9072 added by rprabu for     Sprint 27: EDI Error Report
PROCEDURE NOTIFY_EDI_DISCREPANCY_REPORT ( P_ENTRP_ID  in  number, P_FILE_NAME varchar2  )
IS
  l_notif_id          NUMBER;
  l_acc_id            NUMBER;
 --- l_cc_address        VARCHAR2(255);
  l_template_subject  VARCHAR2(4000);
  l_template_body     VARCHAR2(32000);
  l_to_address        VARCHAR2(255);
  l_employee_name     VARCHAR2(255);
  l_email             VARCHAR2(4000);
  l_tax_id            VARCHAR2(30);
  l_primary_email     VARCHAR2(4000);
  l_super_admin_email VARCHAR2(4000);
  l_edi_flag          VARCHAR2(1)  := 'N';
  l_cc_address        VARCHAR2(4000);
  l_edi_contact       VARCHAR2(4000);
BEGIN

  pc_log.log_error('PC_CLAIM.Notify_EDI_DISCREPANCY_REPORT','p_entrp_id  '||p_entrp_id );
  get_template_body('EDI_DISCREPANCY_REPORT ',l_template_subject,l_template_body,l_cc_address,l_to_address);

  l_tax_id := pc_entrp.get_tax_id(p_entrp_id);

   -- Added by Jaggi for Ticket#9547
   l_acc_id := pc_entrp.get_acc_id(P_ENTRP_ID);
   l_edi_flag := pc_account.get_edi_flag(l_tax_id);

    IF USER = 'SAM' THEN
       l_cc_address := 'ClientServices@sterlingadministration.com,EDI@sterlingadministration.com';
    ELSE
       --l_email := 'IT-team@sterlingadministration.com';
        l_cc_address := 'VHSQATeam@sterlingadministration.com,VHS-IT@sterlingadministration.com';
    END IF;
  --## 9537 added By Jaggi
  SELECT LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)
    INTO l_primary_email
    FROM (SELECT DISTINCT email
    FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(l_tax_id,'EDI'))
   UNION
  SELECT DISTINCT email
           FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(l_tax_id,'PRIMARY')));

  l_super_admin_email :=  PC_CONTACT.GET_SUPER_ADMIN_EMAIL(l_tax_id);

  IF l_primary_email IS NOT NULL THEN
     l_email := l_primary_email;
  END IF;

  IF l_super_admin_email IS NOT NULL THEN
     IF l_email IS NOT NULL THEN
        l_email := l_email ||','||l_super_admin_email;
     ELSE
        l_Email := l_super_admin_email;
     END IF;
  END IF;

  IF l_email IS NOT NULL AND l_edi_flag = 'Y' THEN

    l_template_subject  := 'Your EDI Discrepancy Report is available for review ' ;

    PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
            (P_FROM_ADDRESS     => 'ClientServices@sterlingadministration.com'
            ,P_TO_ADDRESS       => l_email
            ,P_CC_ADDRESS       => l_cc_address
            ,P_SUBJECT          => l_template_subject
            ,P_MESSAGE_BODY     => l_template_body
            ,P_ACC_ID           => l_acc_id
            ,P_USER_ID          => 0
            ,P_TEMPLATE_NAME    => 'EDI_DISCREPANCY_REPORT'
            ,X_NOTIFICATION_ID  => l_notif_id );

    PC_NOTIFICATIONS.SET_TOKEN ('EDI_FILE_NAME',   P_file_name ,l_notif_id);

    UPDATE EMAIL_NOTIFICATIONS
       SET MAIL_STATUS      = 'READY'
     WHERE NOTIFICATION_ID  = l_notif_id;
  END IF;

END  NOTIFY_EDI_DISCREPANCY_REPORT;
-- Added by Jagadeesh
  PROCEDURE INSERT_NOTIFICATIONS
           (P_FROM_ADDRESS     IN VARCHAR2
           ,P_TO_ADDRESS       IN VARCHAR2
           ,P_CC_ADDRESS       IN VARCHAR2
           ,P_SUBJECT          IN VARCHAR2
           ,P_MESSAGE_BODY     IN VARCHAR2
           ,P_USER_ID          IN NUMBER
           ,P_ACC_ID           IN NUMBER DEFAULT NULL
           ,P_TEMPLATE_NAME    IN VARCHAR2
           ,X_NOTIFICATION_ID  OUT NUMBER)
      IS
   BEGIN
     IF p_to_address IS NOT NULL THEN
          INSERT INTO EMAIL_NOTIFICATIONS
          (NOTIFICATION_ID
          ,FROM_ADDRESS
          ,TO_ADDRESS
          ,CC_ADDRESS
          ,SUBJECT
          ,MESSAGE_BODY
          ,MAIL_STATUS
          ,TEMPLATE_NAME
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,ACC_ID)
          VALUES
          (NOTIFICATION_SEQ.NEXTVAL
          ,P_FROM_ADDRESS
          ,P_TO_ADDRESS
          ,P_CC_ADDRESS
          ,P_SUBJECT
          ,P_MESSAGE_BODY
          ,'OPEN'
          ,P_TEMPLATE_NAME
          ,SYSDATE
          ,P_USER_ID
          ,SYSDATE
          ,P_USER_ID
          ,P_ACC_ID) RETURNING NOTIFICATION_ID INTO X_NOTIFICATION_ID;
     END IF;
   END INSERT_NOTIFICATIONS;

     -- Added by Joshi 9141
       PROCEDURE SEND_GA_ER_NOTIFICATION(P_ACC_ID     IN  NUMBER
                                        , P_Source    IN  VARCHAR2    -- Added by Swamy for Ticket#11368(broker)
                                        , X_NOTIFY_ID OUT NUMBER)
      IS
              l_notify_id           NUMBER;
              l_email               varchar2(2000);
               l_cc_address         VARCHAR2(4000);
              l_account_status      varchar2(30);
              l_account_type        varchar2(255);
              l_account_type_desc   varchar2(255);
              l_acc_num             varchar2(20);
              l_entrp_id            NUMBER;
              L_template_name       varchar2(255);
              l_cnt                 NUMBER;
              L_URL                 varchar2(2000);
              L_PAGE                varchar2(2000) := Null; -------9474 rprabu 10/09/2020
              l_enrolle_type        account.enrolle_type%type;
              l_renewed_by          varchar2(30);   -- Added by Swamy for Ticket#11368(broker)
              l_source              varchar2(30) := P_Source;    -- Added by Swamy for Ticket#11368(broker)
              l_enroll_renewal_type varchar2(30);    -- Added by Swamy for Ticket#11368(broker)
              l_type                varchar2(30);    -- Added by Swamy for Ticket#11368(broker)
              l_signature_account_status    varchar2(30);  -- Added by Swamy for Ticket#11368(broker)
              l_acct_status         varchar2(30);  -- Added by Swamy for Ticket#11368(broker)

      BEGIN

       SELECT ACCOUNT_STATUS,ACCOUNT_TYPE, ACC_NUM, ENTRP_ID,DECODE(enrolle_type,'GA','General Agent',INITCAP(enrolle_type)),DECODE(UPPER(renewed_by),'GA','General Agent',INITCAP(renewed_by)),signature_account_status  -- Added by Swamy for Ticket#11368(broker)  -- added by Swamy for Ticket#9617
         INTO l_acct_status, l_account_type, l_acc_num, l_entrp_id, l_enrolle_type,l_renewed_by,l_signature_account_status
         FROM ACCOUNT A
        WHERE ACC_ID = P_ACC_ID ;

       -- Added by Swamy for Ticket#11368(broker)
       IF p_source = 'RENEWAL' THEN
          l_type := l_renewed_by;
          l_account_status := l_signature_account_status;
       ELSE
          l_type := l_enrolle_type;
          l_account_status := l_acct_status;
       END IF;

        -- Check the login /*Added by Jagadeesh*/
        SELECT COUNT(*)
          INTO l_cnt
          FROM ENTERPRISE E,ONLINE_USERS U
         WHERE E.entrp_code = U.tax_id
           AND E.entrp_id   = l_entrp_id;

         IF USER = 'SAMDEV' THEN
                    IF l_cnt > 0 THEN
                       l_URL := '<a href="https://dev.sterlinghsa.com/Accounts/Login/">Click Here to Login</a>';
                    ELSE
                       l_URL := '<a href="https://dev.sterlinghsa.com/Accounts/Register/register2/">Click Here to Register</a>';
                    END IF;
          ELSIF USER = 'SAMQA' THEN
                    IF l_cnt > 0 THEN
                       l_URL := '<a href="https://qa.sterlinghsa.com/Accounts/Login/">Click Here to Login</a>';
                    ELSE
                       l_URL := '<a href="https://qa.sterlinghsa.com/Accounts/Register/register2/">Click Here to Register</a>';
                    END IF;
          ELSIF USER = 'SAMDEMO' THEN
                    IF l_cnt > 0 THEN
                       l_URL := '<a href="https://demo.sterlinghsa.com/Accounts/Login/">Click Here to Login</a>';
                    ELSE
                       l_URL := '<a href="https://demo.sterlinghsa.com/Accounts/Register/register2/">Click Here to Register</a>';
                    END IF;
          ELSIF USER = 'SAM' THEN
                    IF l_cnt > 0 THEN
                       l_URL := '<a href="https://www.sterlinghsa.com/Accounts/Login/">Click Here to Login</a>';
                    ELSE
                       l_URL := '<a href="https://www.sterlinghsa.com/Accounts/Register/register2/">Click Here to Register</a>';
                    END IF;
        END IF;

        -- added by Jaggi #11596
        IF USER = 'SAM' THEN
             -- l_cc_address := 'accountmanagement@sterlingadministration.com';
             l_cc_address :=  null;   -- Joshi 11978  
        ELSE
            l_cc_address := 'IT-team@sterlingadministration.com';
        END IF;

          -- Get the email recipients
        FOR Y IN (SELECT DISTINCT EMAIL EMAIL,DECODE(source,'RENEWAL','Renewal','Enrollment') enroll_renewal_type    -- Added by Swamy for Ticket#11368(broker)
                    FROM ONLINE_COMPLIANCE_STAGING co
                   WHERE ENTRP_ID = l_entrp_id
                     AND BATCH_NUMBER = ( SELECT MAX(ci.BATCH_NUMBER)
                    FROM ONLINE_COMPLIANCE_STAGING ci
                   WHERE ci.ENTRP_ID = co.ENTRP_ID )
                   UNION
                   SELECT DISTINCT EMAIL EMAIL,DECODE(source,'RENEWAL','Renewal','Enrollment') enroll_renewal_type
                    FROM Online_fsa_hra_staging co
                   WHERE ENTRP_ID = l_entrp_id
                     AND BATCH_NUMBER = ( SELECT MAX(ci.BATCH_NUMBER)
                    FROM Online_fsa_hra_staging ci
                   WHERE ci.ENTRP_ID = co.ENTRP_ID ))

        LOOP
            l_email := Y.email ;
            l_enroll_renewal_type := y.enroll_renewal_type;
        END LOOP;

      pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION','p_entrp_id  '||l_entrp_id );


        IF l_account_status = 6  THEN
          IF p_source = 'RENEWAL' THEN
             L_template_name := 'ER_RENEWAL_CONFIRMATION_BY_GA_SIGN_REQ';
          ELSE
             L_template_name := 'ER_ENROLLMENT_CONFIRMATION_BY_GA_SIGN_REQ';
          END IF;

             IF l_cnt > 0 THEN           -------9474 rprabu 10/09/2020
                L_PAGE  :=   '<P>Please click on the link to be directed to our login page where you can Login to your account.
                                         After you successfully login, click on the link shown on the top of your page to be directed the application to review and sign. <BR> </P>';
            Else
               L_PAGE  :=        '  <P>Please click the link to be directed to our Registration page where you can register your account.
                                                    To Register for online access, keep your account number handy (only one account is needed to register).
                                                   After you successfully login post registration, click on the link shown on the top of your page to be directed the application to review and sign.  <BR> </P> ';
           End If;
          ELSIF l_account_status = 8 THEN
             IF p_source = 'RENEWAL' THEN
                L_template_name := 'ER_RENEWAL_CONFIRMATION_BY_GA_SIGN_PAYMENT_REQ';
             ELSE
                L_template_name := 'ER_ENROLLMENT_CONFIRMATION_BY_GA_SIGN_PAYMENT_REQ';
             END IF;

             IF l_cnt > 0 THEN           -------9474 rprabu 10/09/2020
                L_PAGE  := ' <P>Please click on the link below to be directed to our login page.
                                      To login, enter your credentials and click the Login button to access your account(s). After successful login,
                                     click on the link shown on the top of the page to be directed the application to review, enter your payment information, and sign to finalize it. </P> ';
            Else
               L_PAGE  := ' <P> Please click on the link below to be directed to our registration page. If you need to register for online access,
                                         keep your account number handy (only one account is needed to register) and select the option to Register.
                                      To login after registration, enter your credentials and click on Login button. After successful login, click on the link shown on the top of the page to be directed the application to review, enter your payment information, and sign to finalize it.  </P> ';
           End If;

         ELSE
         pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION 12','p_entrp_id  '||l_entrp_id );
                  For X IN  (  SELECT  c.email  notify_email
                                 FROM  Account a ,  Enterprise e ,  Contact  c
                                WHERE  a.entrp_id = e.entrp_id
                                  AND  a.acc_id  = p_acc_id --p_acc_id
                                  AND  A.ACCOUNT_TYPE = c.ACCOUNT_TYPE
                                  AND  e.entrp_code =  c.entity_id
                                  and  C.entity_type ='ENTERPRISE'
                                  and  c. contact_type = 'PRIMARY'   )  ----    union select 'r.prabu@sterlinghsa.com'  notify_email  from dual  )
                 LOOP
                           l_email := x.notify_email ;
                         IF l_cnt > 0 THEN           -------9474 rprabu 10/09/2020
                            IF p_source = 'RENEWAL' THEN
                               L_template_name := 'ER_RENEWAL_CONFIRMATION_BY_GA_LOGIN';   ------- ' Login ';  ticket 9497  17/09/2020 rprabu
                            ELSE
                               L_template_name := 'ER_ENROLLMENT_CONFIRMATION_BY_GA_LOGIN';
                            END IF;
                          Else
                            IF p_source = 'RENEWAL' THEN
                               L_template_name := 'ER_RENEWAL_CONFIRMATION_BY_GA_REGISTER';   ------- ' Register '; ticket 9497  17/09/2020 rprabu
                            ELSE
                               L_template_name := 'ER_ENROLLMENT_CONFIRMATION_BY_GA_REGISTER';
                            END IF;
                       End If;
                          pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION 1 ','L_template_name  '||L_template_name );
                        pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION 1 ','l_email  '||l_email );
                 END LOOP;

                END IF;

        -- Get account type desc.
        SELECT pc_lookups.GET_ACCOUNT_TYPE(l_account_type)
          INTO l_account_type_desc
          FROM DUAL;

        IF USER = 'SAM' THEN
             L_EMAIL := L_EMAIL;
        ELSE
             L_EMAIL := L_EMAIL;
            -- L_EMAIL := 'IT-team@sterlingadministration.com';
        END IF;

      pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION 2','l_email  '||l_email );
       FOR X IN ( SELECT a.template_subject
                        ,  a.template_body
                        ,  a.to_address
                        ,  a.cc_address
                    FROM   NOTIFICATION_TEMPLATE A
                    WHERE  NOTIFICATION_TYPE = 'EXTERNAL'
                      AND  TEMPLATE_NAME = L_template_name
                      AND  STATUS = 'A')
         LOOP

             IF l_email IS NOT NULL THEN
                  PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                 (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                 ,P_TO_ADDRESS      => l_email
--                 ,P_CC_ADDRESS      => x.cc_address
                  ,P_CC_ADDRESS      => CASE WHEN l_account_status IN (6,8) THEN l_cc_address ELSE x.cc_address END     -- added by Jaggi #11596
                 --,P_SUBJECT         => x.template_subject
                 ,P_SUBJECT          => replace(x.template_subject,'<<ENROLLE_RENEWAL_TYPE>>',l_enroll_renewal_type)    -- Added by Swamy for Ticket#11368(broker)
                 ,P_MESSAGE_BODY    => x.template_body
                 ,P_USER_ID         => 0
                 ,P_ACC_ID          => P_ACC_ID
                 ,P_TEMPLATE_NAME   => l_template_name
                 ,X_NOTIFICATION_ID => X_NOTIFY_ID );

                 PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_TYPE', l_account_type_desc,X_NOTIFY_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUMBER', trim(l_acc_num),X_NOTIFY_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('LINK_URL', l_URL,X_NOTIFY_ID );
                 --PC_NOTIFICATIONS.SET_TOKEN ('ENROLLE_TYPE', l_enrolle_type,X_NOTIFY_ID);    -- added by Swamy for Ticket#9617
                 -- Commented above and Added below by Swamy for Ticket#11368(broker)
                 PC_NOTIFICATIONS.SET_TOKEN ('ENROLLE_TYPE', l_type,X_NOTIFY_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ENROLLE_RENEWAL_TYPE', l_enroll_renewal_type,X_NOTIFY_ID);     -- Added by Swamy for Ticket#11368(broker)
               If L_PAGE Is not null Then
                  PC_NOTIFICATIONS.SET_TOKEN ('PAGE', L_PAGE,X_NOTIFY_ID );    ------9474 rprabu 10/09/2020
              End If;

                 UPDATE EMAIL_NOTIFICATIONS
                    SET MAIL_STATUS = 'READY'
                  WHERE NOTIFICATION_ID  = X_NOTIFY_ID;


               pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION 3','X_NOTIFY_ID  '||X_NOTIFY_ID );
              END IF;

        END LOOP;

     Exception    WHEN OTHERS THEN
         pc_log.log_error('pc_notifications.SEND_GA_ER_NOTIFICATION','error message  :  '||SQLERRM );
      END SEND_GA_ER_NOTIFICATION;
--- Ticket 9537 added by Jaggi for     Sprint 31: EDI Contact
PROCEDURE Notify_EDI_file_received ( P_ENTRP_ID  in  number, P_FILE_NAME varchar2  )
IS
  l_notif_id          NUMBER;
  l_acc_id            NUMBER;
  l_template_subject  VARCHAR2(4000);
  l_template_body     VARCHAR2(32000);
  l_to_address        VARCHAR2(255);
  l_employee_name     VARCHAR2(255);
  l_email             VARCHAR2(4000);
  l_tax_id            VARCHAR2(30);
  l_edi_flag          VARCHAR2(1)  := 'N';
  l_cc_address        VARCHAR2(4000);
  l_edi_contact       VARCHAR2(4000);
  l_acc_type          VARCHAR2(255);
BEGIN

  pc_log.log_error('PC_CLAIM.Notify_EDI_file_received','p_entrp_id  '||p_entrp_id );
  get_template_body('EDI_FILE_NOTIFY',l_template_subject,l_template_body,l_cc_address,l_to_address);

   l_tax_id             := pc_entrp.get_tax_id(p_entrp_id);
   l_acc_id             := pc_entrp.get_acc_id(P_ENTRP_ID);
   l_edi_flag           := pc_account.get_edi_flag(l_tax_id);
   l_acc_type           := pc_account.get_account_type(l_acc_id);

    SELECT LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)
      INTO l_edi_contact
      FROM (SELECT DISTINCT email
      FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(l_tax_id,'EDI')));

    IF USER = 'SAM' THEN
       l_cc_address := 'ClientServices@sterlingadministration.com,EDI@sterlingadministration.com';
    ELSE
       --l_email := 'IT-team@sterlingadministration.com';
        l_cc_address := 'VHSQATeam@sterlingadministration.com,VHS-IT@sterlingadministration.com';
    END IF;

    IF l_edi_contact IS NOT NULL AND l_edi_flag = 'Y' THEN

    PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
            (P_FROM_ADDRESS     => 'edi@sterlingadministration.com'
            ,P_TO_ADDRESS       => l_edi_contact
            ,P_CC_ADDRESS       => l_cc_address
            ,P_SUBJECT          => l_template_subject
            ,P_MESSAGE_BODY     => l_template_body
            ,P_ACC_ID           => l_acc_id
            ,P_USER_ID          => 0
            ,P_TEMPLATE_NAME    => 'EDI_FILE_NOTIFY'
            ,X_NOTIFICATION_ID  => l_notif_id );

    PC_NOTIFICATIONS.SET_TOKEN ('EDI_FILE_NAME',   P_file_name ,l_notif_id);
    PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_TYPE',   l_acc_type ,l_notif_id);

    UPDATE EMAIL_NOTIFICATIONS
       SET MAIL_STATUS      = 'READY'
     WHERE NOTIFICATION_ID  = l_notif_id;
    END IF;
END  Notify_EDI_file_received;
-- Added by Jaggi #9902
PROCEDURE NOTIFY_BROKER_AUTH_REQUIRED (P_BROKER_NAME VARCHAR2, P_ACC_ID IN NUMBER, P_USER_ID IN NUMBER )
IS
  l_notify_id         NUMBER;
  l_template_subject  VARCHAR2(4000);
  l_template_body     VARCHAR2(32000);
  l_to_address        VARCHAR2(255);
  l_cc_address        VARCHAR2(4000);
  l_primary_email     VARCHAR2(4000);
  l_super_admin_email VARCHAR2(4000);
  l_acc_num           VARCHAR2(255);
  L_URL               VARCHAR2(2000);
  L_entrp_code        VARCHAR2(20);
BEGIN

  pc_log.log_error('PC_CLAIM.NOTIFY_BROKER_AUTH_REQUIRED','P_ACC_ID  '||P_ACC_ID );
  get_template_body('BROKER_AUTHORIZE_REQUEST_TO_ER',l_template_subject,l_template_body,l_cc_address,l_to_address);

   FOR X IN (SELECT PC_CONTACT.GET_SUPER_ADMIN_EMAIL(REPLACE(ENTRP_CODE,'-')) SUPER_ADMIN_EMAIL
                   ,A.ACC_NUM
                   ,C.ENTRP_CODE
               FROM ACCOUNT A, ENTERPRISE C
              WHERE A.ENTRP_ID = C.ENTRP_ID
                AND A.ACC_ID   = P_ACC_ID)
   LOOP
        l_acc_num := X.ACC_NUM;
        l_entrp_code := X.entrp_code;
        l_super_admin_email := X.SUPER_ADMIN_EMAIL;
   END LOOP;

    FOR Y IN ( SELECT template_subject
                     ,template_body
                     ,to_address
                     ,cc_address
                     ,template_name
                 FROM NOTIFICATION_TEMPLATE
                WHERE NOTIFICATION_TYPE = 'EXTERNAL'
                  AND TEMPLATE_NAME = 'BROKER_AUTHORIZE_REQUEST_TO_ER'
                  AND STATUS = 'A')
    LOOP

        IF USER = 'SAMDEV' THEN
                       l_URL := '<a href=https://dev.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
          ELSIF USER = 'SAMQA' THEN
                       l_URL := '<a href=https://qa.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
          ELSIF USER = 'SAMDEMO' THEN
                       l_URL := '<a href=https://demo.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
          ELSIF USER = 'SAM' THEN
                       l_URL := '<a href=https://www.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
        END IF;


      SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM (select distinct email
        FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(l_entrp_code,'PRIMARY')));

        --email address
        IF l_primary_email IS NULL THEN
            l_to_address := l_super_admin_email;
        ELSE
            l_to_address := l_primary_email ||','||l_super_admin_email;
        END IF;

            PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
            (P_FROM_ADDRESS     => 'customer.service@sterlingadministration.com'
            ,P_TO_ADDRESS       => l_to_address
            ,P_CC_ADDRESS       => l_cc_address
            ,P_SUBJECT          => Y.TEMPLATE_SUBJECT
            ,P_MESSAGE_BODY     => l_template_body
            ,P_ACC_ID           => P_ACC_ID
            ,P_USER_ID          => P_USER_ID
            ,P_TEMPLATE_NAME    => Y.TEMPLATE_NAME
            ,X_NOTIFICATION_ID  => l_notify_id );

               PC_NOTIFICATIONS.SET_TOKEN ('BROKER_NAME',  P_BROKER_NAME ,l_notify_id);
               PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUM',  L_ACC_NUM ,l_notify_id);
               PC_NOTIFICATIONS.SET_TOKEN ('LINK_URL',     l_URL ,l_notify_id);

           UPDATE EMAIL_NOTIFICATIONS
              SET MAIL_STATUS = 'READY'
            WHERE NOTIFICATION_ID = l_notify_id;

    END LOOP;
END  NOTIFY_BROKER_AUTH_REQUIRED;

-- Added by Jaggi #9902
PROCEDURE NOTIFY_BROKER_REQ_APPROVED (P_ACC_ID IN NUMBER,P_USER_ID IN NUMBER)
IS
  l_notify_id         NUMBER;
  l_template_subject  VARCHAR2(4000);
  l_template_body     VARCHAR2(32000);
  l_to_address        VARCHAR2(4000);
  l_primary_email     VARCHAR2(4000);
  l_broker_email      VARCHAR2(4000);
  l_cc_address        VARCHAR2(4000);
  l_name              VARCHAR2(200);
  l_entrp_code        VARCHAR2(20);
  l_broker_lic        VARCHAR2(20);
BEGIN

  get_template_body('ER_APPROVE_BROKER_AUTHORIZE_REQUEST',l_template_subject,l_template_body,l_cc_address,l_to_address);

    FOR K IN (SELECT C.ENTRP_CODE
                    ,C.NAME
                    ,PC_SALES_TEAM.get_salesrep_email(A.AM_ID) Email
                    ,Broker_LIC
                FROM ACCOUNT A, ENTERPRISE C , Broker B
              WHERE A.ENTRP_ID = C.ENTRP_ID
                AND A.Broker_id = B.Broker_ID
                AND A.ACC_ID = P_ACC_ID )
    LOOP
         l_name := K.NAME;
         l_entrp_code := K.entrp_code;
         l_cc_address := NVL(K.email,'Renewals@SterlingAdministration.com');
         l_broker_lic := k.Broker_lic;
    END LOOP;

     -- added by jaggi #10248
      SELECT LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL) INTO l_to_address
        FROM (SELECT DISTINCT Email
                FROM online_users
               WHERE emp_reg_type = 2
                 AND user_status = 'A' -- added by Jaggi
                 AND user_type = 'B'     -- Added by Joshi for wrong email id issue
                 AND upper(find_key) = upper(l_broker_lic));

    FOR Y IN ( SELECT template_subject
                     ,template_body
                     ,to_address
                     ,cc_address
                     ,template_name
                 FROM NOTIFICATION_TEMPLATE
                WHERE NOTIFICATION_TYPE = 'EXTERNAL'
                  AND TEMPLATE_NAME = 'ER_APPROVE_BROKER_AUTHORIZE_REQUEST'
                  AND STATUS = 'A')
    LOOP

            PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
            (P_FROM_ADDRESS     => 'customer.service@sterlingadministration.com'
            ,P_TO_ADDRESS       => l_to_address
            ,P_CC_ADDRESS       => l_cc_address
            ,P_SUBJECT          => Y.TEMPLATE_SUBJECT
            ,P_MESSAGE_BODY     => l_template_body
            ,P_ACC_ID           => P_ACC_ID
            ,P_USER_ID          => P_USER_ID
            ,P_TEMPLATE_NAME    => Y.TEMPLATE_NAME
            ,X_NOTIFICATION_ID  => l_notify_id );

               PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',l_name ,l_notify_id);

           UPDATE EMAIL_NOTIFICATIONS
              SET    MAIL_STATUS = 'READY'
            WHERE  NOTIFICATION_ID  = l_notify_id;
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
     pc_log.log_error('PC_NOTIFICATIONS.NOTIFY_BROKER_REQ_APPROVED IN exception ERREUR ',sqlerrm);
END NOTIFY_BROKER_REQ_APPROVED;

-- Added by Jaggi #10431
PROCEDURE SEND_APP_CORRECTION_MAIL (P_ACC_ID IN NUMBER, P_ENROLLED_BY IN NUMBER, P_SEND_BACK_NOTES VARCHAR2, P_ACTION VARCHAR2,P_ACTION_BY VARCHAR2)
IS
  l_notify_id          NUMBER;
  l_acc_id             NUMBER;
  l_user_id            NUMBER;
  l_user               VARCHAR2(20);
  l_acc_num            VARCHAR2(20);
  l_enrolle_type       VARCHAR2(10);
  l_renewed_by         VARCHAR2(10);
  l_url                VARCHAR2(2000);
  l_template_subject   VARCHAR2(4000);
  l_template_body      VARCHAR2(32000);
  l_to_address         VARCHAR2(4000);
  l_primary_email      VARCHAR2(4000);
  l_super_admin_email  VARCHAR2(4000);
  l_cc_address         VARCHAR2(4000);
  l_note               VARCHAR2(200);
  l_entrp_code         VARCHAR2(20);
  l_broker_lic         VARCHAR2(20);
  l_broker_id          VARCHAR2(20);
  l_ga_id              VARCHAR2(20);
  l_renewal_resubmit_flag  VARCHAR2(20);  -- Added by Swamy for Ticket#11636
  l_name               VARCHAR2(100);     -- Added by Swamy for Ticket#11636
  l_email              VARCHAR2(100);     -- Added by Swamy for Ticket#11636
  l_review_resubmit    VARCHAR2(100);     -- Added by Swamy for Ticket#11636
  l_account_type       VARCHAR2(100);     -- Added by Swamy for Ticket#11636

BEGIN
pc_log.log_error('pc_notifications.SEND_APP_CORRECTION_MAIL IN begin P_ACTION ',P_ACTION||'P_ACTION_BY := '||P_ACTION_BY);
    get_template_body('APP_CORRECTION_TEMPLATE',l_template_subject,l_template_body,l_cc_address,l_to_address);

    l_acc_id    := p_acc_id;
    l_note      := p_send_back_notes;

    SELECT SYS_CONTEXT ('USERENV', 'CURRENT_SCHEMA')  INTO l_user FROM DUAL;

    IF l_user = 'SAMDEV' THEN
       l_url := '<a href=https://dev.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
    ELSIF l_user = 'SAMQA' THEN
       l_url := '<a href=https://qa.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
    ELSIF l_user = 'SAMDEMO' THEN
       l_url := '<a href=https://demo.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
    ELSIF l_user = 'SAM' THEN
       l_url := '<a href=https://www.sterlinghsa.com/Accounts/Login/>Click Here to Login</a>';
    END IF;

    FOR X IN (SELECT c.entrp_code
                    ,a.acc_num
                    ,NVL(enrolle_type,'EMPLOYER') enrolle_type
                    ,NVL(renewed_by,'EMPLOYER') renewed_by
                    ,broker_id
                    ,Ga_Id
                    ,renewal_resubmit_flag
                    ,c.name                   -- Added by Swamy for Ticket#11636
                    ,a.account_type
                FROM ACCOUNT A, ENTERPRISE C
               WHERE A.ENTRP_ID = C.ENTRP_ID
                 AND A.ACC_ID   = P_ACC_ID)
    LOOP
        l_entrp_code            := x.entrp_code;
        l_acc_num               := x.acc_num;
        l_enrolle_type          := x.enrolle_type;
        l_template_subject      := 'Sterling Application ' ||   x.acc_num   || ' Requesting for Re-submission';
        l_renewed_by            := x.renewed_by;
        l_broker_id             := x.broker_id;
        l_ga_id                 := x.ga_id;
        l_renewal_resubmit_flag := x.renewal_resubmit_flag;
        l_name                  := x.name;         -- Added by Swamy for Ticket#11636
        l_account_type          := x.account_type;  -- Added by Swamy for Ticket#11636
    END LOOP;

    IF l_user = 'SAM' THEN   -- Added by Swamy for Ticket#11636
        IF P_ACTION = 'E' THEN
            l_cc_address := 'install@sterlingadministration.com';
            l_email      := 'customer.service@sterlingadministration.com';   -- Added by Swamy for Ticket#11636
            l_review_resubmit := 'Re-submit application';                    -- Added by Swamy for Ticket#11636
        ELSIF P_ACTION = 'R' THEN
            l_cc_address := 'Renewals@sterlingadministration.com';  -- Replaced 'accountmanagement@sterlingadministration.com' by Swamy for Ticket#11636
            l_email      := l_cc_address;    -- Added by Swamy for Ticket#11636
            l_review_resubmit := 'Review ';                    -- Added by Swamy for Ticket#11636
        END IF;
    ELSE
       l_cc_address := 'it-team@sterlingadministration.com';
        IF P_ACTION = 'E' THEN
            l_email      := 'customer.service@sterlingadministration.com';   -- Added by Swamy for Ticket#11636
            l_review_resubmit := 'Re-submit application';                    -- Added by Swamy for Ticket#11636
        ELSIF P_ACTION = 'R' THEN
            l_email      := 'Renewals@sterlingadministration.com';    -- Added by Swamy for Ticket#11636
            l_review_resubmit := 'Review ';                    -- Added by Swamy for Ticket#11636
        END IF;
    END IF;

    IF P_ACTION = 'E' OR l_account_type <> 'COBRA' THEN
        IF P_ACTION_BY IN ('BROKER') THEN
           SELECT nvl(broker_lic,l_entrp_code)
             INTO l_entrp_code
             FROM broker
            WHERE Broker_id = l_broker_id ;
        ELSIF P_ACTION_BY = 'GA' THEN
            SELECT nvl(ga_lic,l_entrp_code)
              INTO l_entrp_code
              FROM General_Agent
             WHERE ga_id = l_ga_id ;
        END IF;
    END IF;

IF NVL(l_renewal_resubmit_flag,'N') = 'Y' AND l_account_type <> 'COBRA' THEN   -- Added by Swamy for Ticket#11636
    FOR Y IN  (SELECT LISTAGG(email, ',') WITHIN GROUP (ORDER BY email) email
                 FROM ONLINE_USERS
                WHERE TAX_ID       = l_entrp_code
                  AND EMP_REG_TYPE = 2
                AND USER_STATUS    = 'A' )
    LOOP
        l_to_address     := y.email;
    END LOOP;
pc_log.log_error('pc_notifications.SEND_APP_CORRECTION_MAIL calling insert notifications l_entrp_code ',l_entrp_code||'P_ACTION_BY :='||P_ACTION_BY);
ELSIF P_ACTION = 'R' AND l_account_type = 'COBRA' THEN
    IF P_ACTION_BY IN ('BROKER','GA') THEN
        FOR Y IN (SELECT LISTAGG(email, ',') WITHIN GROUP (ORDER BY email) email
                    FROM CONTACT a, CONTACT_ROLE b
                  WHERE REPLACE(strip_bad(a.entity_id),'-') = REPLACE(strip_bad(l_entrp_code),'-')
                       AND nvl(a.status,'A') = 'A'
                       and a.end_date is null
                       AND a.entity_type = 'ENTERPRISE'
                       AND a.contact_id = b.contact_id
                       AND b.role_type = P_ACTION_BY
                       AND A.CAN_CONTACT = 'Y'
                       AND b.EFFECTIVE_END_DATE IS NULL)
        LOOP
           l_to_address     := y.email;
        END LOOP;
    ELSE
        FOR Y IN  (SELECT LISTAGG(email, ',') WITHIN GROUP (ORDER BY email) email
                     FROM ONLINE_USERS
                    WHERE TAX_ID       = l_entrp_code
                      AND EMP_REG_TYPE = 2
                    AND USER_STATUS    = 'A' )
        LOOP
            l_to_address     := y.email;
        END LOOP;
    END IF;

else
    FOR Y IN  (SELECT LISTAGG(email, ',') WITHIN GROUP (ORDER BY email) email
                 FROM ONLINE_USERS
                WHERE TAX_ID       = l_entrp_code
                  AND EMP_REG_TYPE = 2
                  AND USER_TYPE    =  CASE WHEN P_ACTION = 'E' THEN decode(l_enrolle_type,'EMPLOYER','E','BROKER','B','GA','G')
                                          WHEN P_ACTION = 'R' THEN decode(l_renewed_by,'EMPLOYER','E','BROKER','B','GA','G')
                                     END
                AND USER_STATUS    = 'A' )
    LOOP
        l_to_address     := y.email;
    END LOOP;
 end if;


    FOR Y IN ( SELECT template_subject
                     ,template_body
                     ,to_address
                     ,cc_address
                     ,template_name
                FROM NOTIFICATION_TEMPLATE
               WHERE NOTIFICATION_TYPE = 'EXTERNAL'
                 AND TEMPLATE_NAME     = 'APP_CORRECTION_TEMPLATE'
                 AND STATUS = 'A')
    LOOP
pc_log.log_error('pc_notifications.SEND_APP_CORRECTION_MAIL calling insert notifications l_to_address ',l_to_address);
PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
            (P_FROM_ADDRESS      => 'customer.service@sterlingadministration.com'
            ,P_TO_ADDRESS        => l_to_address
            ,P_CC_ADDRESS        => l_cc_address
            ,P_SUBJECT           => l_template_subject
            ,P_MESSAGE_BODY      => l_template_body
            ,P_ACC_ID            => l_acc_id
            ,P_USER_ID           => p_enrolled_by
            ,P_TEMPLATE_NAME     => Y.template_name
            ,X_NOTIFICATION_ID   =>  l_notify_id );

             PC_NOTIFICATIONS.SET_TOKEN ('NOTE',l_note ,l_notify_id);
             PC_NOTIFICATIONS.SET_TOKEN ('LINK_URL',l_url ,l_notify_id);
             PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUM',l_acc_num ,l_notify_id);
             PC_NOTIFICATIONS.SET_TOKEN ('GROUP_NAME',l_name ,l_notify_id);    -- Added by Swamy for Ticket#11636
             PC_NOTIFICATIONS.SET_TOKEN ('EMAIL',l_email ,l_notify_id);    -- Added by Swamy for Ticket#11636
             PC_NOTIFICATIONS.SET_TOKEN ('REVIEW',l_review_resubmit,l_notify_id);    -- Added by Swamy for Ticket#11636


       UPDATE EMAIL_NOTIFICATIONS
              SET MAIL_STATUS = 'READY'
        WHERE NOTIFICATION_ID  = l_notify_id;

    END LOOP;
EXCEPTION
WHEN OTHERS THEN
     pc_log.log_error('PC_NOTIFICATIONS.SEND_APP_CORRECTION_MAIL IN exception ERREUR ',sqlerrm);
END SEND_APP_CORRECTION_MAIL;

-- Added by Swamy for Ticket#10747
  PROCEDURE NOTIFY_BROKER_REN_DECL_PLAN(P_ACC_ID       IN VARCHAR2,
                                        P_USER_ID      IN VARCHAR2,
                                        P_ENTRP_ID     IN VARCHAR2,
                                        P_BEN_PLN_NAME IN VARCHAR2,
                                        P_REN_DEC_FLG  IN VARCHAR2,
                                        P_ACC_NUM      IN VARCHAR2
                                        ) IS
     L_NOTIFICATION_ID    NUMBER;
     L_NUM_TBL            PC_NOTIFICATIONS.NUMBER_TBL;
     L_SALES_REP_EMAIL    VARCHAR2(4000);
     L_EMAIL              VARCHAR2(4000);
     L_ENTRP_EMAIL        VARCHAR2(4000);
     L_EMAIL_CSS          VARCHAR2(4000);
     L_TO_ADDRESS         VARCHAR2(4000);
     L_CC_ADDRESS         VARCHAR2(4000);
     l_account_type       VARCHAR2(100):=pc_account.get_account_type(p_acc_id);
     L_plan_type          VARCHAR2(100);
     num_tbl              number_tbl;
     l_broker_id          broker.broker_id%type;
     l_USER_TYPE          VARCHAR2(10);
    -- l_TEMPLATE_NAME      VARCHAR2(100);
    -- l_name               VARCHAR2(500);
    -- l_PAY_ACCT_FEES      VARCHAR2(100);
  BEGIN
     L_TO_ADDRESS  := NULL;
     L_CC_ADDRESS := NULL;

           FOR I IN (SELECT a.email,b.broker_id,a.USER_TYPE
                       FROM ONLINE_USERS a, broker b
                      WHERE USER_ID       = P_USER_ID
                        --AND EMP_REG_TYPE IN (2,4)
                        AND USER_STATUS = 'A'
                        AND USER_TYPE = 'B'
                        and a.find_key = b.broker_lic)
          LOOP
                  L_TO_ADDRESS := I.EMAIL;
                  l_broker_id := i.broker_id;
                  l_USER_TYPE  := i.USER_TYPE;
            END LOOP;

 /*  FOR j IN (SELECT a.ACCOUNT_TYPE,b.name,DECODE(P_PAY_ACCT_FEES,'GA','General Agent','BROKER','Broker','EMPLOYER','Employer') PAY_ACCT_FEES
              FROM account a,enterprise b
             WHERE a.acc_id = p_acc_id
               AND a.entrp_id = b.entrp_id) LOOP
     l_name           := j.name;
     l_PAY_ACCT_FEES  := j.PAY_ACCT_FEES;
   END LOOP;

   IF l_account_type = 'COBRA' THEN      -- Added by Swamy for Ticket#11364
      l_TEMPLATE_NAME := 'BROKER_PLAN_RENEWAL_ONLINE_COBRA';
   ELSE
      l_TEMPLATE_NAME := 'BROKER_PLAN_RENEWAL_ONLINE';
   END IF;
   */
  -- pc_log.log_error('PC_NOTIFICATIONS.NOTIFY_BROKER_REN_DECL_PLAN l_account_type ',l_account_type||' l_USER_TYPE :='||l_USER_TYPE||' l_TEMPLATE_NAME :='||l_TEMPLATE_NAME);
IF  NVL(l_USER_TYPE,'*') = 'B' THEN
     IF P_REN_DEC_FLG = 'R' THEN
        FOR I IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         NVL(A.CC_ADDRESS, CASE WHEN l_account_type IN ('FSA', 'HRA') THEN
                                                'clientservices@sterlingadministration.com'
                                               WHEN l_account_type = 'COBRA' THEN
                                               'cobra@sterlingadministration.com'
                                               WHEN l_account_type IN ('ERISA_WRAP','POP','FORM_5500') THEN
                                               'compliance@sterlingadministration.com'
                                               ELSE
                                                'customer.service@sterlingadministration.com' end) CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'BROKER_PLAN_RENEWAL_ONLINE'    -- Added by Swamy for Ticket#11364
                     AND A.STATUS        = 'A') LOOP


             IF USER NOT IN ('SAM') THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
             END IF;

                L_CC_ADDRESS := CASE WHEN L_CC_ADDRESS IS NULL THEN I.CC_ADDRESS
                                     ELSE L_CC_ADDRESS||','||I.CC_ADDRESS END;


              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS
                           ,P_CC_ADDRESS      => L_CC_ADDRESS
                           ,P_SUBJECT         => replace(I.TEMPLATE_SUBJECT,'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => I.TEMPLATE_BODY
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'BROKER_PLAN_RENEWAL_ONLINE'    -- Added by Swamy for Ticket#11364
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

              PC_NOTIFICATIONS.SET_TOKEN ('BROKER_NAME',pc_broker.get_broker_name(l_broker_id),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,l_account_type),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('DATE',TO_CHAR(SYSDATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN_SUBJECT ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
             -- PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYER_NAME',l_name,L_NOTIFICATION_ID);           -- Added by Swamy for Ticket#11364
            --  PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_TYPE',l_account_type,L_NOTIFICATION_ID);     -- Added by Swamy for Ticket#11364
            --  PC_NOTIFICATIONS.SET_TOKEN ('PAY_ACCT_FEES',l_PAY_ACCT_FEES,L_NOTIFICATION_ID);   -- Added by Swamy for Ticket#11364
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

             UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     END IF;
    END IF;
  END NOTIFY_BROKER_REN_DECL_PLAN;

 -- Added by Swamy for Ticket#10747
 PROCEDURE NOTIFY_BROKER_HRA_FSA_PLAN_RENEW(P_ACC_ID       IN VARCHAR2,
                                            P_PLAN_TYPE    IN VARCHAR2,
                                            P_ACC_NUM      IN VARCHAR2,
                                            P_BEN_PLAN_ID  IN VARCHAR2,
                                            P_PRODUCT_TYPE IN VARCHAR2,
                                            P_USER_ID      IN VARCHAR2,
                                            P_ENTRP_ID     IN VARCHAR2) IS
     L_NOTIFICATION_ID    NUMBER;
     L_TEMPLATE_SUB       VARCHAR2(4000);
     L_TEMPLATE_BOD       VARCHAR2(4000);
     L_CC_EMAIL           VARCHAR2(4000);
     L_NAME               VARCHAR2(4000);
     L_ADDRESS            VARCHAR2(4000);
     L_ADDRESS2           VARCHAR2(4000);
     L_ENTRP_EMAIL        VARCHAR2(4000);
     L_EMAIL              VARCHAR2(4000);
     L_COVERAGE_TYPE1     VARCHAR2(4000);
     L_COVERAGE_TYPE2     VARCHAR2(4000);
     L_COVERAGE_TYPE3     VARCHAR2(4000);
     L_DEDUCTIBLE1        VARCHAR2(4000);
     L_ROLLOVER1          VARCHAR2(4000);
     L_DEDUCTIBLE2        VARCHAR2(4000);
     L_ROLLOVER2          VARCHAR2(4000);
     L_DEDUCTIBLE3        VARCHAR2(4000);
     L_ROLLOVER3          VARCHAR2(4000);
     num_tbl number_tbl;
     L_TO_ADDRESS         VARCHAR2(4000);
     L_CC_ADDRESS         VARCHAR2(4000);
     L_SALES_REP_EMAIL    VARCHAR2(4000);
     l_USER_TYPE          VARCHAR2(10);
     l_template_name      VARCHAR2(100);
  BEGIN
     L_TO_ADDRESS  := NULL;
     L_CC_ADDRESS := NULL;

       FOR I IN (SELECT a.email,b.broker_id,a.USER_TYPE
                   FROM ONLINE_USERS a, broker b
                  WHERE USER_ID       = P_USER_ID
                    --AND EMP_REG_TYPE IN (2,4)
                    AND USER_STATUS = 'A'
                    AND USER_TYPE = 'B'
                    and a.find_key = b.broker_lic)
      LOOP
              L_TO_ADDRESS := I.EMAIL;
              l_USER_TYPE := i.USER_TYPE;
      END LOOP;

pc_log.log_error('NOTIFY_BROKER_HRA_FSA_PLAN_RENEW','Before Email' ||l_USER_TYPE);
pc_log.log_error('NOTIFY_BROKER_HRA_FSA_PLAN_RENEW','Before Email' ||P_BEN_PLAN_ID);

IF  NVL(l_USER_TYPE,'*') = ('B') THEN
     L_CC_ADDRESS     := 'clientservices@sterlingadministration.com';
     IF P_PRODUCT_TYPE = 'FSA' THEN
        L_TEMPLATE_SUB := NULL;
        L_TEMPLATE_BOD := NULL;

        FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         A.CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'BROKER_ONLINE_RENEWAL_FSA'
                     AND A.STATUS = 'A') LOOP
            L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
            L_TEMPLATE_BOD := J.TEMPLATE_BODY;
            IF J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
        END LOOP;

        FOR K IN (SELECT A.NAME,
                         A.ADDRESS,
                         A.CITY||' '||A.STATE||' '||A.ZIP ADDRESS2,
                         A.ENTRP_EMAIL
                    FROM ENTERPRISE A
                   WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
            L_NAME        := K.NAME;
            L_ADDRESS     := K.ADDRESS;
            L_ADDRESS2    := K.ADDRESS2;
            L_ENTRP_EMAIL := K.ENTRP_EMAIL;
        END LOOP;

        FOR I IN (SELECT A.*
                    FROM BEN_PLAN_ENROLLMENT_SETUP A
                   WHERE BEN_PLAN_ID = P_BEN_PLAN_ID) LOOP

             IF USER NOT IN ('SAM') THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
             END IF;
 pc_log.log_error('NOTIFY_BROKER_HRA_FSA_PLAN_RENEW','Before Email' ||P_BEN_PLAN_ID);
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS
                           ,P_CC_ADDRESS      => L_CC_ADDRESS
                           ,P_SUBJECT         => replace(replace(L_TEMPLATE_SUB,'<<ACCOUNT>>',p_acc_num),'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => L_TEMPLATE_BOD
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'BROKER_ONLINE_RENEWAL_FSA'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              PC_NOTIFICATIONS.SET_TOKEN ('RENEWAL_DATE',TO_CHAR(I.RENEWAL_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_NAME',L_NAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD1',L_ADDRESS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD2',L_ADDRESS2,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,L_NOTIFICATION_ID);

              /* Ticket#5168.Hard coded ; has been removed */
              IF I.PLAN_TYPE = 'FSA' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('HEALTHCARE_FSA_H','<b>Healthcare FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H','Annual Election : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H','Funding : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H','Rollover : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H','Grace : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H','Runout : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H','Non-Discrimination Testing : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'FSA_FUNDING_OPTION')||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER',I.ROLLOVER||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE',I.GRACE_PERIOD||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT',I.RUNOUT_PERIOD_DAYS||' '||I.RUNOUT_PERIOD_TERM||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('HEALTHCARE_FSA_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'LPF' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('LIMITED_PURPOSE_FSA_H','<b>Limited Purpose FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H1','Annual Election : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H1','Funding : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H1','Rollover : ' ,L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H1','Grace : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H1','Runout : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H1','Non-Discrimination Testing : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_1',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_1',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'FSA_FUNDING_OPTION')||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_1',I.ROLLOVER||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_1',I.GRACE_PERIOD||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_1',I.RUNOUT_PERIOD_DAYS||' '||I.RUNOUT_PERIOD_TERM||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('LIMITED_PURPOSE_FSA_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H1','' ,L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_1','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'DCA' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('DEPENDENT_CARE_FSA','<b>Dependent Care FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_2',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>'||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H2','Annual Election : ',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('DEPENDENT_CARE_FSA','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H2','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'TRN' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('TRANSIT_FSA', '<b>Transit FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('TRANSIT_FSA','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'PKG' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('PARKING_FSA','<b>Parking FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('PARKING_FSA','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'UA1' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('BIKE_FSA','<b>Bike FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('BIKE_FSA','',L_NOTIFICATION_ID);
              END IF;

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS     = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     ELSIF P_PRODUCT_TYPE = 'HRA' THEN
        L_TEMPLATE_SUB := NULL;
        L_TEMPLATE_BOD := NULL;

        FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         A.CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'BROKER_ONLINE_RENEWAL_HRA'
                     AND A.STATUS = 'A') LOOP
            L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
            L_TEMPLATE_BOD := J.TEMPLATE_BODY;
           if J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
         END LOOP;

        FOR K IN (SELECT A.NAME,
                         A.ADDRESS,
                         A.CITY||' '||A.STATE||' '||A.ZIP ADDRESS2,
                         A.ENTRP_EMAIL
                    FROM ENTERPRISE A
                   WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
            L_NAME      := K.NAME;
            L_ADDRESS   := K.ADDRESS;
            L_ADDRESS2  := K.ADDRESS2;
            L_ENTRP_EMAIL := K.ENTRP_EMAIL;
        END LOOP;

        FOR I IN (SELECT RENEWAL_DATE,
                         DECODE (NEW_HIRE_CONTRIB, 'PRORATE', 'Y', 'N') NEW_HIRE_CONTRIB,
                         NON_DISCRM_FLAG,
                         PLAN_START_DATE,
                         PLAN_END_DATE,
                         RUNOUT_PERIOD_DAYS,
                         EOB_REQUIRED,
                         FUNDING_OPTIONS
                    FROM BEN_PLAN_ENROLLMENT_SETUP A
                   WHERE BEN_PLAN_ID = P_BEN_PLAN_ID) LOOP
              L_COVERAGE_TYPE1  := NULL;
              L_COVERAGE_TYPE2  := NULL;
              L_COVERAGE_TYPE3  := NULL;
              L_ROLLOVER1       := NULL;
              L_ROLLOVER2       := NULL;
              L_ROLLOVER3       := NULL;
              L_DEDUCTIBLE1     := NULL;
              L_DEDUCTIBLE2     := NULL;
              L_DEDUCTIBLE3     := NULL;

             IF USER NOT IN ('SAM') THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
             END IF;

              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => l_to_address
                           ,P_CC_ADDRESS      => l_cc_address
                           ,P_SUBJECT         => replace(replace(L_TEMPLATE_SUB,'<<ACCOUNT>>',p_acc_num),'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => L_TEMPLATE_BOD
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'BROKER_ONLINE_RENEWAL_HRA'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              PC_NOTIFICATIONS.SET_TOKEN ('RENEWAL_DATE',TO_CHAR(I.RENEWAL_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_NAME',L_NAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD1',L_ADDRESS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD2',L_ADDRESS2,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_OPT',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'HRA_FUNDING_OPTION'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('RUN_OUT',I.RUNOUT_PERIOD_DAYS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('EOB',I.EOB_REQUIRED,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PRORATE',I.NEW_HIRE_CONTRIB,L_NOTIFICATION_ID);

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE =  'SINGLE')LOOP
                  L_COVERAGE_TYPE1  := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE1     := K.DEDUCTIBLE;
                  L_ROLLOVER1       := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE NOT IN('SINGLE','EE_FAMILY'))LOOP
                  L_COVERAGE_TYPE2 := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE2    := K.DEDUCTIBLE;
                  L_ROLLOVER2      := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE = 'EE_FAMILY')LOOP
                  L_COVERAGE_TYPE3 := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE3    := K.DEDUCTIBLE;
                  L_ROLLOVER3      := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              IF L_COVERAGE_TYPE1 IS NOT NULL OR L_COVERAGE_TYPE2 IS NOT NULL OR L_COVERAGE_TYPE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('COVERAGE_TIER','; Coverage Tier (s)</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('COVERAGE_TIER','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE1 IS NOT NULL OR L_DEDUCTIBLE2 IS NOT NULL OR L_DEDUCTIBLE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLES','; Deductibles </br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLES','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER1 IS NOT NULL OR L_ROLLOVER2 IS NOT NULL OR L_ROLLOVER3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','; Rollover </br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY',L_COVERAGE_TYPE1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_1','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY',L_COVERAGE_TYPE2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_2','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY',L_COVERAGE_TYPE3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY1','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_1',L_DEDUCTIBLE1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_11','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_1',L_DEDUCTIBLE2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_11','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_22','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_1',L_DEDUCTIBLE3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_22','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY2','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_2',L_ROLLOVER1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_111','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_2',L_ROLLOVER2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_111','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_222','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_2',L_ROLLOVER3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_222','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              PC_NOTIFICATIONS.SET_TOKEN ('FUNDING','Funding',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_PERIOD','Runout Period',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PRORATE_H','Prorate New Hire Elections',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('EOB_H','EOB Required',L_NOTIFICATION_ID);
              --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCRM','Non-Discrimination Testing',L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
      END IF;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
          pc_log.log_error('NOTIFY_BROKER_HRA_FSA_PLAN_RENEW','Others' ||(SQLERRM)||' for ben plan id :='||P_BEN_PLAN_ID);
  END NOTIFY_BROKER_HRA_FSA_PLAN_RENEW;


 -- Added by Jaggi #11119
 -- Added by Jaggi #11119
 PROCEDURE DAILY_SETUP_RENEWAL_INVOICE_NOTIFY(P_BATCH_NUMBER IN NUMBER, P_SOURCE IN VARCHAR2)
 IS
   l_sql            VARCHAR2(32000);
   l_to_address     VARCHAR2(2000);
   l_subject        VARCHAR2(2000);
   l_file_name      VARCHAR2(100);
   l_html_msg       VARCHAR2(4000);
   l_account_type   VARCHAR2(10);
  BEGIN

    FOR X IN (SELECT account_type
                FROM daily_enroll_renewal_account_info
               WHERE batch_number = p_batch_number
                 AND error_status = 'S')
    LOOP
        l_account_type := x.account_type;
    END LOOP;

 l_sql :=  'SELECT  invoice_id
                  ,employer_name
                  ,start_date
                  ,end_date
                  ,acc_num
                  ,invoice_date
                  ,invoice_due_date
                  ,invoice_amount
                  ,pending_amount
                  ,discount_amount
                  ,status
                  ,auto_pay
                  ,batch_number
                  ,product_type
                  ,plan_type
                  ,billing_name
                  ,division_name
                 ,error_message
              FROM daily_setup_renewal_invoice_v
             WHERE batch_number = ' || p_batch_number || '
               AND source = ''' ||p_source || '''';

        IF p_source = 'SETUP' THEN
            l_to_address := 'install@sterlingadministration.com,finance.department@sterlingadministration.com,IT-Team@sterlingadministration.com';
            l_subject        := 'Daily Online Enrollment Invoice Report';
            l_file_name    := 'Daily_Online_Enrollment_Invoice_Report_'||to_char(sysdate,'MMDDYYYY')||'.xls';
            l_html_msg    := '<html><body><br><p>Daily # New Enrollment  Invoice Report for the Date '||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'</p><br><br></body></html>';

       ELSIF p_source = 'RENEWAL' THEN
            l_to_address := 'finance.department@sterlingadministration.com,IT-Team@sterlingadministration.com';
            l_subject        := 'Daily Online Renewal Invoice Report';
            l_file_name    := 'Daily_Online_Renewal_Invoice_Report_'||to_char(sysdate,'MMDDYYYY')||'.xls';
            l_html_msg    := '<html><body><br><p>Daily # New Renewal Invoice Report for the Date '||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'</p><br><br></body></html>';

       END IF;

       IF USER IN ('SAMDEV', 'SAMQA') THEN
            l_to_address := 'IT-Team@sterlingadministration.com';
       END IF;

   PC_LOG.LOG_ERROR('pc_notifications.Daily_Setup_Renewal_Invoice_Notif: l_to_address ', l_to_address);
   PC_LOG.LOG_ERROR('pc_notifications.Daily_Setup_Renewal_Invoice_Notif: l_file_name ', l_file_name);
--   PC_LOG.LOG_ERROR('pc_notifications.Daily_Setup_Renewal_Invoice_Notif: l_sql ', l_sql);
   PC_LOG.LOG_ERROR('pc_notifications.Daily_Setup_Renewal_Invoice_Notif: l_subject ', l_subject);
    --dbms_output.put_line('Daily_Setup_Renewal_Invoice_Notif1 '||l_sql);
     mail_utility.report_emails('oracle@sterlingadministration.com'
                               ,l_to_address
                               ,l_file_name
                               ,l_sql
                               ,l_html_msg
                               ,l_subject
                               );
    EXCEPTION
      WHEN OTHERS THEN
-- Close the file if something goes wrong.
      PC_LOG.LOG_ERROR('pc_notifications.Daily_Setup_Renewal_Invoice_Notif: error message ', SQLERRM);
       PC_LOG.LOG_ERROR('pc_notifications.Daily_Setup_Renewal_Invoice_Notif: l_sql ', l_sql);
   --   dbms_output.put_line('Daily_Setup_Renewal_Invoice_Notif2 '||l_sql);
  END DAILY_SETUP_RENEWAL_INVOICE_NOTIFY;

-- Added by Jaggi #11265
PROCEDURE Get_Cobra_Welcome_Letters
IS
  l_acc_id              NUMBER;
  l_plan_selection_type VARCHAR2(100);
BEGIN

FOR X IN (SELECT *
   FROM ( SELECT a.acc_id,rpd.coverage_type
            FROM ar_quote_headers arh
                ,ar_quote_lines arl
                ,rate_plan_detail rpd
                ,pay_reason pr
                ,rate_plans rp
                ,account a
           WHERE arh.entrp_id =  a.entrp_id
             AND rp.rate_plan_id = arl.rate_plan_id
             AND arh.quote_header_id = arl.quote_header_id
             AND rp.rate_plan_id = rpd.rate_plan_id
             AND arl.rate_plan_detail_id = rpd.rate_plan_detail_id
             AND rpd.rate_code = pr.reason_code
             AND rpd.rate_code = pr.reason_code
             AND trunc(a.verified_date) = trunc(sysdate-1)
             AND a.enrollment_source = 'ONLINE'
             AND a.account_type = 'COBRA'
             AND a.account_status = 1)
           PIVOT (count(1) FOR coverage_type in ( 'MAIN_COBRA_SERVICE' AS main_cobra_service, 'OPTIONAL_COBRA_SERVICE_CN' AS optional_cobra_service_cn,
                                                  'OPEN_ENROLLMENT_SUITE' AS open_enrollment_suite,'OPTIONAL_COBRA_SERVICE_SC' AS optional_cobra_service_sc)))
LOOP
    l_acc_id := x.acc_id;

   IF x.optional_cobra_service_cn = 0 AND x.open_enrollment_suite = 0 AND x.optional_cobra_service_sc = 0 THEN
        l_plan_selection_type := 'COBRA_BASIC_SERVICE_WELCOME_EMAIL';
   ELSIF x.optional_cobra_service_cn = 1 AND x.open_enrollment_suite = 1 AND x.optional_cobra_service_sc = 0 THEN
        l_plan_selection_type := 'COBRA_BASIC_SERVICE_WELCOME_EMAIL';
   ELSIF x.optional_cobra_service_cn = 0 AND x.open_enrollment_suite = 1 AND x.optional_cobra_service_sc = 1 THEN
        l_plan_selection_type := 'COBRA_BASIC_SERVICE_WELCOME_EMAIL';
   ELSIF x.optional_cobra_service_cn = 1 AND x.open_enrollment_suite = 0 AND x.optional_cobra_service_sc = 1 THEN
        l_plan_selection_type := 'COBRA_BASIC_SERVICE_WELCOME_EMAIL';
   ELSIF x.optional_cobra_service_cn = 0 AND x.open_enrollment_suite = 1 AND x.optional_cobra_service_sc = 0 THEN
        l_plan_selection_type := 'COBRA_BASIC_OE_WELCOME_EMAIL';
    ELSIF x.optional_cobra_service_cn = 1 AND x.open_enrollment_suite = 0 AND x.optional_cobra_service_sc = 0 THEN
        l_plan_selection_type := 'COBRA_CARRIER_NOTIFICATION_WELCOME_EMAIL';
   ELSIF x.optional_cobra_service_cn = 1 AND x.open_enrollment_suite = 1 AND x.optional_cobra_service_sc = 1 THEN
        l_plan_selection_type := 'COBRA_ALL_OPTIONAL_SERVICE_WELCOME_EMAIL';
   ELSIF x.optional_cobra_service_cn = 0 AND x.open_enrollment_suite = 0 AND x.optional_cobra_service_sc = 1 THEN
        l_plan_selection_type := 'COBRA_BASIC_TEXAS_STATE_CONTINUATION_EMAIL';
  END IF;

        Get_Cobra_Welcome_Letter_Body(l_acc_id , l_plan_selection_type);
END LOOP;

END Get_Cobra_Welcome_Letters;

-- Added by Jaggi #11265
PROCEDURE Get_Cobra_Welcome_Letter_Body(p_acc_id IN NUMBER, p_plan_selection_type IN VARCHAR2)
IS
  l_notify_id           NUMBER;
  l_user_id             NUMBER;
  l_template_subject    VARCHAR2(4000);
  l_template_body       VARCHAR2(32000);
  l_to_address          VARCHAR2(4000);
  l_cc_address          VARCHAR2(4000);
  l_name                VARCHAR2(200);
  l_sales_manager       VARCHAR2(200);
  l_primary_email       VARCHAR2(4000);
  l_entrp_code          VARCHAR2(20);
  l_effective_date      VARCHAR2(20);
BEGIN

    FOR K IN (SELECT c.name
                    ,c.entrp_code
                    ,a.salesrep_id
                    ,replace(o.effective_date,'/','-') effective_date
                FROM ACCOUNT A, ENTERPRISE C ,online_compliance_staging O
               WHERE a.entrp_id = c.entrp_id
                 AND a.acc_id = p_acc_id
                 AND a.entrp_id = o.entrp_id
                 AND o.source IS NULL )
    LOOP
         l_name          := k.name;
         l_sales_manager := pc_sales_team.get_sales_rep_name(k.salesrep_id);
         l_entrp_code    := k.entrp_code;
         l_effective_date:= k.effective_date;
    END LOOP;

      SELECT LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_primary_email
        FROM ( select distinct email
        FROM TABLE(pc_contact.get_contact_info(l_entrp_code,'PRIMARY'))WHERE Account_type = 'COBRA');

  get_template_body(p_plan_selection_type,l_template_subject,l_template_body,l_cc_address,l_to_address);

    FOR Y IN ( SELECT template_subject
                     ,template_body
                     ,to_address
                     ,cc_address
                     ,template_name
                 FROM NOTIFICATION_TEMPLATE
                WHERE NOTIFICATION_TYPE = 'EXTERNAL'
                  AND TEMPLATE_NAME = p_plan_selection_type
                  AND STATUS = 'A')
    LOOP
            PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
            (P_FROM_ADDRESS     => 'customer.service@sterlingadministration.com'
            ,P_TO_ADDRESS       => l_primary_email
            ,P_CC_ADDRESS       => l_cc_address
            ,P_SUBJECT          => replace(replace(l_template_subject,'<<ER_NAME>>',l_name),'<<DATE>>',l_effective_date)
            ,P_MESSAGE_BODY     => l_template_body
            ,P_ACC_ID           => p_acc_id
            ,P_USER_ID          => l_user_id
            ,P_TEMPLATE_NAME    => Y.template_name
            ,X_NOTIFICATION_ID  => l_notify_id );

               PC_NOTIFICATIONS.SET_TOKEN ('ER_NAME',l_name ,l_notify_id);
               PC_NOTIFICATIONS.SET_TOKEN ('SALESS_MANAGER',l_sales_manager ,l_notify_id);

           UPDATE email_notifications
              SET mail_status = 'READY'
            WHERE notification_id  = l_notify_id;
    END LOOP;

END Get_Cobra_Welcome_Letter_Body;
-- Added by Jaggi for Ticket#11368
PROCEDURE NOTIFY_GA_HRA_FSA_PLAN_RENEW (P_ACC_ID       IN VARCHAR2,
                                        P_PLAN_TYPE    IN VARCHAR2,
                                        P_ACC_NUM      IN VARCHAR2,
                                        P_BEN_PLAN_ID  IN VARCHAR2,
                                        P_PRODUCT_TYPE IN VARCHAR2,
                                        P_USER_ID      IN VARCHAR2,
                                        P_ENTRP_ID     IN VARCHAR2) IS
     L_NOTIFICATION_ID    NUMBER;
     L_TEMPLATE_SUB       VARCHAR2(4000);
     L_TEMPLATE_BOD       VARCHAR2(4000);
     L_CC_EMAIL           VARCHAR2(4000);
     L_NAME               VARCHAR2(4000);
     L_ADDRESS            VARCHAR2(4000);
     L_ADDRESS2           VARCHAR2(4000);
     L_ENTRP_EMAIL        VARCHAR2(4000);
     L_EMAIL              VARCHAR2(4000);
     L_COVERAGE_TYPE1     VARCHAR2(4000);
     L_COVERAGE_TYPE2     VARCHAR2(4000);
     L_COVERAGE_TYPE3     VARCHAR2(4000);
     L_DEDUCTIBLE1        VARCHAR2(4000);
     L_ROLLOVER1          VARCHAR2(4000);
     L_DEDUCTIBLE2        VARCHAR2(4000);
     L_ROLLOVER2          VARCHAR2(4000);
     L_DEDUCTIBLE3        VARCHAR2(4000);
     L_ROLLOVER3          VARCHAR2(4000);
     num_tbl number_tbl;
     L_TO_ADDRESS         VARCHAR2(4000);
     L_CC_ADDRESS         VARCHAR2(4000);
     L_SALES_REP_EMAIL    VARCHAR2(4000);
     l_USER_TYPE          VARCHAR2(10);
     l_template_name      VARCHAR2(100);
  BEGIN
     L_TO_ADDRESS  := NULL;
     L_CC_ADDRESS := NULL;

       FOR I IN (SELECT a.email,G.GA_id,a.USER_TYPE
                   FROM ONLINE_USERS a, GENERAL_AGENT G
                  WHERE USER_ID       = P_USER_ID
                    --AND EMP_REG_TYPE IN (2,4)
                    AND USER_STATUS = 'A'
                    AND USER_TYPE = 'G'
                    and a.find_key = G.ga_lic)
      LOOP
              L_TO_ADDRESS := I.EMAIL;
              l_USER_TYPE := i.USER_TYPE;
      END LOOP;

pc_log.log_error('NOTIFY_GA_HRA_FSA_PLAN_RENEW','Before Email' ||l_USER_TYPE);
pc_log.log_error('NOTIFY_GA_HRA_FSA_PLAN_RENEW','Before Email' ||P_BEN_PLAN_ID);

IF  NVL(l_USER_TYPE,'*') = ('G') THEN
     L_CC_ADDRESS     := 'clientservices@sterlingadministration.com';
     IF P_PRODUCT_TYPE = 'FSA' THEN
        L_TEMPLATE_SUB := NULL;
        L_TEMPLATE_BOD := NULL;

        FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         A.CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'GA_ONLINE_RENEWAL_FSA'
                     AND A.STATUS = 'A') LOOP
            L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
            L_TEMPLATE_BOD := J.TEMPLATE_BODY;
            IF J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
        END LOOP;

        FOR K IN (SELECT A.NAME,
                         A.ADDRESS,
                         A.CITY||' '||A.STATE||' '||A.ZIP ADDRESS2,
                         A.ENTRP_EMAIL
                    FROM ENTERPRISE A
                   WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
            L_NAME        := K.NAME;
            L_ADDRESS     := K.ADDRESS;
            L_ADDRESS2    := K.ADDRESS2;
            L_ENTRP_EMAIL := K.ENTRP_EMAIL;
        END LOOP;

        FOR I IN (SELECT A.*
                    FROM BEN_PLAN_ENROLLMENT_SETUP A
                   WHERE BEN_PLAN_ID = P_BEN_PLAN_ID) LOOP

             IF USER NOT IN ('SAM') THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
             END IF;
 pc_log.log_error('NOTIFY_BROKER_HRA_FSA_PLAN_RENEW','Before Email' ||P_BEN_PLAN_ID);
              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS
                           ,P_CC_ADDRESS      => L_CC_ADDRESS
                           ,P_SUBJECT         => replace(replace(L_TEMPLATE_SUB,'<<ACCOUNT>>',p_acc_num),'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => L_TEMPLATE_BOD
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'GA_ONLINE_RENEWAL_FSA'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              PC_NOTIFICATIONS.SET_TOKEN ('RENEWAL_DATE',TO_CHAR(I.RENEWAL_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_NAME',L_NAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD1',L_ADDRESS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD2',L_ADDRESS2,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,L_NOTIFICATION_ID);

              /* Ticket#5168.Hard coded ; has been removed */
              IF I.PLAN_TYPE = 'FSA' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('HEALTHCARE_FSA_H','<b>Healthcare FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H','Annual Election : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H','Funding : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H','Rollover : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H','Grace : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H','Runout : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H','Non-Discrimination Testing : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'FSA_FUNDING_OPTION')||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER',I.ROLLOVER||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE',I.GRACE_PERIOD||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT',I.RUNOUT_PERIOD_DAYS||' '||I.RUNOUT_PERIOD_TERM||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('HEALTHCARE_FSA_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'LPF' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('LIMITED_PURPOSE_FSA_H','<b>Limited Purpose FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H1','Annual Election : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H1','Funding : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H1','Rollover : ' ,L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H1','Grace : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H1','Runout : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H1','Non-Discrimination Testing : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_1',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_1',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'FSA_FUNDING_OPTION')||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_1',I.ROLLOVER||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_1',I.GRACE_PERIOD||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_1',I.RUNOUT_PERIOD_DAYS||' '||I.RUNOUT_PERIOD_TERM||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('LIMITED_PURPOSE_FSA_H','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_H1','' ,L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('NON-DISCRIMINATION_TESTING_H1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('GRACE_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_1','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'DCA' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('DEPENDENT_CARE_FSA','<b>Dependent Care FSA</b></br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_2',NVL(I.MINIMUM_ELECTION,0)||'-'||NVL(I.MAXIMUM_ELECTION,0)||'</br>'||'</br>',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H2','Annual Election : ',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('DEPENDENT_CARE_FSA','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECT_2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('ANNUAL_ELECTION_H2','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'TRN' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('TRANSIT_FSA', '<b>Transit FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('TRANSIT_FSA','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'PKG' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('PARKING_FSA','<b>Parking FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('PARKING_FSA','',L_NOTIFICATION_ID);
              END IF;

              IF I.PLAN_TYPE = 'UA1' THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('BIKE_FSA','<b>Bike FSA </b></br>'||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('BIKE_FSA','',L_NOTIFICATION_ID);
              END IF;

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS     = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     ELSIF P_PRODUCT_TYPE = 'HRA' THEN
        L_TEMPLATE_SUB := NULL;
        L_TEMPLATE_BOD := NULL;

        FOR J IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         A.CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'GA_ONLINE_RENEWAL_HRA'
                     AND A.STATUS = 'A') LOOP
            L_TEMPLATE_SUB := J.TEMPLATE_SUBJECT;
            L_TEMPLATE_BOD := J.TEMPLATE_BODY;
           if J.CC_ADDRESS IS NOT NULL THEN
               L_CC_ADDRESS     := L_CC_ADDRESS||','||J.CC_ADDRESS;
            END IF;
         END LOOP;

        FOR K IN (SELECT A.NAME,
                         A.ADDRESS,
                         A.CITY||' '||A.STATE||' '||A.ZIP ADDRESS2,
                         A.ENTRP_EMAIL
                    FROM ENTERPRISE A
                   WHERE ENTRP_ID  = P_ENTRP_ID ) LOOP
            L_NAME      := K.NAME;
            L_ADDRESS   := K.ADDRESS;
            L_ADDRESS2  := K.ADDRESS2;
            L_ENTRP_EMAIL := K.ENTRP_EMAIL;
        END LOOP;

        FOR I IN (SELECT RENEWAL_DATE,
                         DECODE (NEW_HIRE_CONTRIB, 'PRORATE', 'Y', 'N') NEW_HIRE_CONTRIB,
                         NON_DISCRM_FLAG,
                         PLAN_START_DATE,
                         PLAN_END_DATE,
                         RUNOUT_PERIOD_DAYS,
                         EOB_REQUIRED,
                         FUNDING_OPTIONS
                    FROM BEN_PLAN_ENROLLMENT_SETUP A
                   WHERE BEN_PLAN_ID = P_BEN_PLAN_ID) LOOP
              L_COVERAGE_TYPE1  := NULL;
              L_COVERAGE_TYPE2  := NULL;
              L_COVERAGE_TYPE3  := NULL;
              L_ROLLOVER1       := NULL;
              L_ROLLOVER2       := NULL;
              L_ROLLOVER3       := NULL;
              L_DEDUCTIBLE1     := NULL;
              L_DEDUCTIBLE2     := NULL;
              L_DEDUCTIBLE3     := NULL;

             IF USER NOT IN ('SAM') THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
             END IF;

              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => l_to_address
                           ,P_CC_ADDRESS      => l_cc_address
                           ,P_SUBJECT         => replace(replace(L_TEMPLATE_SUB,'<<ACCOUNT>>',p_acc_num),'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => L_TEMPLATE_BOD
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'GA_ONLINE_RENEWAL_HRA'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

              PC_NOTIFICATIONS.SET_TOKEN ('RENEWAL_DATE',TO_CHAR(I.RENEWAL_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_NAME',L_NAME,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD1',L_ADDRESS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('COMPANY_ADD2',L_ADDRESS2,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACC_NUM',P_ACC_NUM,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN_YEAR',TO_CHAR(I.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(I.PLAN_END_DATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('FUNDING_OPT',PC_LOOKUPS.GET_MEANING(I.FUNDING_OPTIONS,'HRA_FUNDING_OPTION'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('RUN_OUT',I.RUNOUT_PERIOD_DAYS,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('EOB',I.EOB_REQUIRED,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PRORATE',I.NEW_HIRE_CONTRIB,L_NOTIFICATION_ID);

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE =  'SINGLE')LOOP
                  L_COVERAGE_TYPE1  := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE1     := K.DEDUCTIBLE;
                  L_ROLLOVER1       := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE NOT IN('SINGLE','EE_FAMILY'))LOOP
                  L_COVERAGE_TYPE2 := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE2    := K.DEDUCTIBLE;
                  L_ROLLOVER2      := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              FOR K IN (SELECT ANNUAL_ELECTION,
                               DEDUCTIBLE,
                               MAX_ROLLOVER_AMOUNT
                          FROM BEN_PLAN_COVERAGES
                         WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID
                           AND COVERAGE_TYPE = 'EE_FAMILY')LOOP
                  L_COVERAGE_TYPE3 := K.ANNUAL_ELECTION;
                  L_DEDUCTIBLE3    := K.DEDUCTIBLE;
                  L_ROLLOVER3      := K.MAX_ROLLOVER_AMOUNT;
              END LOOP;

              IF L_COVERAGE_TYPE1 IS NOT NULL OR L_COVERAGE_TYPE2 IS NOT NULL OR L_COVERAGE_TYPE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('COVERAGE_TIER','; Coverage Tier (s)</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('COVERAGE_TIER','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE1 IS NOT NULL OR L_DEDUCTIBLE2 IS NOT NULL OR L_DEDUCTIBLE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLES','; Deductibles </br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('DEDUCTIBLES','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER1 IS NOT NULL OR L_ROLLOVER2 IS NOT NULL OR L_ROLLOVER3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','; Rollover </br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('ROLLOVER','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY',L_COVERAGE_TYPE1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_1','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY',L_COVERAGE_TYPE2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_COVERAGE_TYPE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_2','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY',L_COVERAGE_TYPE3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY1','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_1',L_DEDUCTIBLE1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY1','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_11','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_1',L_DEDUCTIBLE2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_11','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_DEDUCTIBLE3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_22','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_1',L_DEDUCTIBLE3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_22','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_1','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER1 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY2','; ; ;Employee Only : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_2',L_ROLLOVER1||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_ONLY2','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER2 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_111','; ; ;Employee + 1 : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_2',L_ROLLOVER2||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_111','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP1_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              IF L_ROLLOVER3 IS NOT NULL THEN
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_222','; ; ;Employee + 2 or more : ',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_2',L_ROLLOVER3||'</br>',L_NOTIFICATION_ID);
              ELSE
                 PC_NOTIFICATIONS.SET_TOKEN ('EMPLOYEE_222','',L_NOTIFICATION_ID);
                 PC_NOTIFICATIONS.SET_TOKEN ('EMP2_ONLY_2','',L_NOTIFICATION_ID);
              END IF;

              PC_NOTIFICATIONS.SET_TOKEN ('FUNDING','Funding',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('RUNOUT_PERIOD','Runout Period',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PRORATE_H','Prorate New Hire Elections',L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('EOB_H','EOB Required',L_NOTIFICATION_ID);
              --PC_NOTIFICATIONS.SET_TOKEN ('NON_DISCRM','Non-Discrimination Testing',L_NOTIFICATION_ID);  -- Commented by Swamy for Ticket#9861

              UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
      END IF;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
          pc_log.log_error('NOTIFY_GA_HRA_FSA_PLAN_RENEW','Others' ||(SQLERRM)||' for ben plan id :='||P_BEN_PLAN_ID);
  END NOTIFY_GA_HRA_FSA_PLAN_RENEW;

-- Added by jaggi for Ticket#11368
  PROCEDURE NOTIFY_GA_REN_DECL_PLAN(P_ACC_ID       IN VARCHAR2,
                                    P_USER_ID      IN VARCHAR2,
                                    P_ENTRP_ID     IN VARCHAR2,
                                    P_BEN_PLN_NAME IN VARCHAR2,
                                    P_REN_DEC_FLG  IN VARCHAR2,
                                    P_ACC_NUM      IN VARCHAR2) IS
     L_NOTIFICATION_ID    NUMBER;
     L_NUM_TBL            PC_NOTIFICATIONS.NUMBER_TBL;
     L_SALES_REP_EMAIL    VARCHAR2(4000);
     L_EMAIL              VARCHAR2(4000);
     L_ENTRP_EMAIL        VARCHAR2(4000);
     L_EMAIL_CSS          VARCHAR2(4000);
     L_TO_ADDRESS         VARCHAR2(4000);
     L_CC_ADDRESS         VARCHAR2(4000);
     l_account_type       VARCHAR2(100):=pc_account.get_account_type(p_acc_id);
     L_plan_type          VARCHAR2(100);
     num_tbl              number_tbl;
     l_ga_id          broker.broker_id%type;
     l_USER_TYPE          VARCHAR2(10);
  BEGIN
     L_TO_ADDRESS  := NULL;
     L_CC_ADDRESS := NULL;

           FOR I IN (SELECT a.email,G.GA_id,a.USER_TYPE
                       FROM ONLINE_USERS a, GENERAL_AGENT G
                      WHERE USER_ID       = P_USER_ID
                        --AND EMP_REG_TYPE IN (2,4)
                        AND USER_STATUS = 'A'
                        AND USER_TYPE = 'G'
                        AND a.find_key = G.ga_lic)
          LOOP
                  L_TO_ADDRESS := I.EMAIL;
                  l_ga_id      := i.ga_id;
                  l_USER_TYPE  := i.USER_TYPE;
            END LOOP;

IF  NVL(l_USER_TYPE,'*') = 'G' THEN
     IF P_REN_DEC_FLG = 'R' THEN
        FOR I IN (SELECT A.TEMPLATE_SUBJECT,
                         A.TEMPLATE_BODY,
                         NVL(A.CC_ADDRESS, CASE WHEN l_account_type IN ('FSA', 'HRA') THEN
                                                'clientservices@sterlingadministration.com'
                                               WHEN l_account_type = 'COBRA' THEN
                                               'cobra@sterlingadministration.com'
                                               WHEN l_account_type IN ('ERISA_WRAP','POP','FORM_5500') THEN
                                               'compliance@sterlingadministration.com'
                                               ELSE
                                                'customer.service@sterlingadministration.com' end) CC_ADDRESS
                    FROM NOTIFICATION_TEMPLATE A
                   WHERE A.TEMPLATE_NAME = 'GA_PLAN_RENEWAL_ONLINE'
                     AND A.STATUS        = 'A') LOOP


             IF USER NOT IN ('SAM') THEN
                L_TO_ADDRESS := 'IT-Team@sterlingadministration.com';
             END IF;

                L_CC_ADDRESS := CASE WHEN L_CC_ADDRESS IS NULL THEN I.CC_ADDRESS
                                     ELSE L_CC_ADDRESS||','||I.CC_ADDRESS END;


              PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                           (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                           ,P_TO_ADDRESS      => L_TO_ADDRESS
                           ,P_CC_ADDRESS      => L_CC_ADDRESS
                           ,P_SUBJECT         => replace(I.TEMPLATE_SUBJECT,'<<NAME>>',pc_entrp.get_entrp_name(p_entrp_id))
                           ,P_MESSAGE_BODY    => I.TEMPLATE_BODY
                           ,P_USER_ID         => P_USER_ID
                           ,P_EVENT           => 'GA_PLAN_RENEWAL_ONLINE'
                           ,P_ACC_ID          => P_ACC_ID
                           ,X_NOTIFICATION_ID => L_NOTIFICATION_ID );

              PC_NOTIFICATIONS.SET_TOKEN ('GA_NAME',PC_GENERAL_AGENT.get_ga_name(L_ga_id),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('PLAN',nvl(P_BEN_PLN_NAME,l_account_type),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN ('DATE',TO_CHAR(SYSDATE,'MM/DD/YYYY'),L_NOTIFICATION_ID);
              PC_NOTIFICATIONS.SET_TOKEN_SUBJECT ('ACCOUNT',P_ACC_NUM,L_NOTIFICATION_ID);
              num_tbl(1) := p_user_id;
              add_notify_users(num_tbl,l_notifICATION_id);

             UPDATE EMAIL_NOTIFICATIONS
                 SET MAIL_STATUS = 'READY'
               WHERE NOTIFICATION_ID = L_NOTIFICATION_ID;
        END LOOP;
     END IF;
    END IF;
  END NOTIFY_GA_REN_DECL_PLAN;

PROCEDURE HRA_FSA_Employer_Balances_report
AS
  l_html_message   VARCHAR2(32000);
  l_sql            VARCHAR2(32000);

BEGIN
   --IF to_char(sysdate,'DD') = '01' THEN

    l_html_message  := '<html>
      <head>
          <title>FSA Employer Balance Report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>FSA Employer Balance Report  </p>
       </table>
        </body>
        </html>';

    l_sql := 'SELECT * FROM TABLE(pc_employer_fin.get_funding_er_balance_by_date(to_date(''12/31/2022'',''mm/dd/yyyy'')));';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com'
                           ,'hra_fsa_employer_balance_12312022' ||'.xls'
                           , l_sql
                           , l_html_message
                          , 'HRA FSA Balance Report for 12/31/2022');

      l_sql := 'SELECT * FROM TABLE(pc_employer_fin.get_funding_er_balance_by_date(to_date(''03/31/2023'',''mm/dd/yyyy'')));';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com'
                           ,'hra_fsa_employer_balance_03312023' ||'.xls'
                           , l_sql
                           , l_html_message
                          , 'HRA FSA Balance Report for 03/31/2023');

       l_sql := 'SELECT * FROM TABLE(pc_employer_fin.get_funding_er_balance_by_date(to_date(''05/31/2023'',''mm/dd/yyyy'')));';


     mail_utility.report_emails('oracle@sterlingadministration.com'
                           ,'shavee.kapoor@sterlingadministration.com'
                           ,'hra_fsa_employer_balance_05312023' ||'.xls'
                           , l_sql
                           , l_html_message
                          , 'HRA FSA Balance Report for 05/31/2023');


 --  END IF;
exception
    WHEN OTHERS THEN
-- Close the file if something goes wrong.

    dbms_output.put_line('error message '||SQLERRM);
END HRA_FSA_Employer_Balances_report;

 PROCEDURE EMPLOYER_HRA_FSA_BAL_REPORT
  IS
   l_utl_id    UTL_FILE.file_type;
   l_file_name VARCHAR2(3200);
   l_line      VARCHAR2(3200);
   l_balance number := 0 ;
   l_employer_name varchar2(500);
   l_product_type  varchar2(500);

 BEGIN

    l_file_name := 'hra_fsa_employer_balance_12312022.csv';
    l_utl_id := utl_file.fopen( 'MAILER_DIR',l_file_name, 'w' );

    L_LINE := 'account no,employer balance,Employer Name, product type';

   UTL_FILE.PUT_LINE( FILE   => L_UTL_ID, BUFFER => L_LINE );

   for x in ( SELECT  DISTINCT b.acc_num, a.entrp_id, a.product_type
                                  FROM    ben_plan_enrollment_setup a , account b
                WHERE   a.entrp_id IS NOT NULL
                AND     B.ACCOUNT_TYPE IN ('HRA','FSA')
                AND     a.product_type IN ('HRA','FSA')
                AND     a.entrp_id = b.entrp_id
                AND     a.funding_options is NOT NULL
                AND     a.funding_options !='-1'    )
   loop
            l_balance := 0;
            l_employer_name := PC_ENTRP.GET_ENTRP_NAME(x.entrp_id) ;
            l_balance  := PC_EMPLOYER_FIN.get_employer_balance(x.entrp_id,to_date('12/31/2022','mm/dd/yyyy') ,x.product_type);
            L_LINE := X.ACC_NUM ||',' ||l_balance||',"'||l_employer_name||'",'||x.product_type;
             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,   BUFFER => L_LINE );
   end loop;

   UTL_FILE.FCLOSE(FILE => L_UTL_ID);

   IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE' THEN
                    mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => 'raghavendra.joshi@sterlingadministration.com, shavee.kapoor@sterlingadministration.com'
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'HRA FSA Balance Report for12/31/2022');
    END IF;

   l_file_name := 'hra_fsa_employer_balance_05312023.csv' ;
  l_utl_id := utl_file.fopen( 'MAILER_DIR',l_file_name, 'w' );

   L_LINE := 'account no,employer balance,Employer Name, product type';

   UTL_FILE.PUT_LINE( FILE   => L_UTL_ID, BUFFER => L_LINE );

  for x in ( SELECT  DISTINCT b.acc_num, a.entrp_id, a.product_type
                                  FROM    ben_plan_enrollment_setup a , account b
                WHERE   a.entrp_id IS NOT NULL
                AND     B.ACCOUNT_TYPE IN ('HRA','FSA')
                AND     a.product_type IN ('HRA','FSA')
                AND     a.entrp_id = b.entrp_id
                AND     a.funding_options is NOT NULL
                AND     a.funding_options !='-1'    )
   loop
            l_balance := 0;
            l_employer_name := PC_ENTRP.GET_ENTRP_NAME(x.entrp_id) ;
            l_balance  := PC_EMPLOYER_FIN.get_employer_balance(x.entrp_id,to_date('05/31/2023','mm/dd/yyyy') ,x.product_type);
            L_LINE := X.ACC_NUM ||',' ||l_balance||',"'||l_employer_name||'",'||x.product_type;
             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,   BUFFER => L_LINE );
   end loop;

   UTL_FILE.FCLOSE(FILE => L_UTL_ID);


    IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE' THEN
                    mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => 'raghavendra.joshi@sterlingadministration.com, shavee.kapoor@sterlingadministration.com'
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'HRA FSA Balance Report for12/31/2022');
    END IF;

   l_file_name := 'hra_fsa_employer_balance_03312023.csv' ;
   l_utl_id := utl_file.fopen( 'MAILER_DIR',l_file_name, 'w' );

   L_LINE := 'account no,employer balance,Employer Name, product type';

   UTL_FILE.PUT_LINE( FILE   => L_UTL_ID, BUFFER => L_LINE );

    for x in ( SELECT  DISTINCT b.acc_num, a.entrp_id, a.product_type
                                  FROM    ben_plan_enrollment_setup a , account b
                WHERE   a.entrp_id IS NOT NULL
                AND     B.ACCOUNT_TYPE IN ('HRA','FSA')
                AND     a.product_type IN ('HRA','FSA')
                AND     a.entrp_id = b.entrp_id
                AND     a.funding_options is NOT NULL
                AND     a.funding_options !='-1'    )
   loop
            l_balance := 0;
            l_employer_name := PC_ENTRP.GET_ENTRP_NAME(x.entrp_id) ;
            l_balance  := PC_EMPLOYER_FIN.get_employer_balance(x.entrp_id,to_date('03/31/2023','mm/dd/yyyy') ,x.product_type);
            L_LINE := X.ACC_NUM ||',' ||l_balance||',"'||l_employer_name||'",'||x.product_type;
             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,   BUFFER => L_LINE );
   end loop;

   UTL_FILE.FCLOSE(FILE => L_UTL_ID);
    IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE' THEN
                    mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => 'raghavendra.joshi@sterlingadministration.com, shavee.kapoor@sterlingadministration.com'
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'HRA FSA Balance Report for12/31/2022');
    END IF;

   END EMPLOYER_HRA_FSA_BAL_REPORT;

   PROCEDURE HRA_FSA_Emp_Bal_report_05312023
  IS
   l_utl_id    UTL_FILE.file_type;
   l_file_name VARCHAR2(3200);
   l_line      VARCHAR2(3200);
   l_balance number := 0 ;
   l_employer_name varchar2(500);
   l_product_type  varchar2(500);

 BEGIN


  l_file_name := 'hra_fsa_employer_balance_05312023.csv' ;
  l_utl_id := utl_file.fopen( 'MAILER_DIR',l_file_name, 'w' );

  L_LINE := 'account no,employer balance,Employer Name, product type';

  UTL_FILE.PUT_LINE( FILE   => L_UTL_ID, BUFFER => L_LINE );

  for x in ( SELECT  DISTINCT b.acc_num, a.entrp_id, a.product_type
                                  FROM    ben_plan_enrollment_setup a , account b
                WHERE   a.entrp_id IS NOT NULL
                AND     B.ACCOUNT_TYPE IN ('HRA','FSA')
                AND     a.product_type IN ('HRA','FSA')
                AND     a.entrp_id = b.entrp_id
                AND     a.funding_options is NOT NULL
                AND     a.funding_options !='-1'    )
   loop
            l_balance := 0;
            l_employer_name := PC_ENTRP.GET_ENTRP_NAME(x.entrp_id) ;
            l_balance  := PC_EMPLOYER_FIN.get_employer_balance(x.entrp_id,to_date('05/31/2023','mm/dd/yyyy') ,x.product_type);
            L_LINE := X.ACC_NUM ||',' ||l_balance||',"'||l_employer_name||'",'||x.product_type;
             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,   BUFFER => L_LINE );
   end loop;

   UTL_FILE.FCLOSE(FILE => L_UTL_ID);


    IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE' THEN
                    mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => 'raghavendra.joshi@sterlingadministration.com, shavee.kapoor@sterlingadministration.com'
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'HRA FSA Balance Report for 05/31/2023');
    END IF;


   END HRA_FSA_Emp_Bal_report_05312023;

     PROCEDURE HRA_FSA_Emp_Bal_report_03312023
  IS
   l_utl_id    UTL_FILE.file_type;
   l_file_name VARCHAR2(3200);
   l_line      VARCHAR2(3200);
   l_balance number := 0 ;
   l_employer_name varchar2(500);
   l_product_type  varchar2(500);

 BEGIN


  l_file_name := 'hra_fsa_employer_balance_03312023.csv' ;
  l_utl_id := utl_file.fopen( 'MAILER_DIR',l_file_name, 'w' );

  L_LINE := 'account no,employer balance,Employer Name, product type';

  UTL_FILE.PUT_LINE( FILE   => L_UTL_ID, BUFFER => L_LINE );

  for x in ( SELECT  DISTINCT b.acc_num, a.entrp_id, a.product_type
                                  FROM    ben_plan_enrollment_setup a , account b
                WHERE   a.entrp_id IS NOT NULL
                AND     B.ACCOUNT_TYPE IN ('HRA','FSA')
                AND     a.product_type IN ('HRA','FSA')
                AND     a.entrp_id = b.entrp_id
                AND     a.funding_options is NOT NULL
                AND     a.funding_options !='-1'    )
   loop
            l_balance := 0;
            l_employer_name := PC_ENTRP.GET_ENTRP_NAME(x.entrp_id) ;
            l_balance  := PC_EMPLOYER_FIN.get_employer_balance(x.entrp_id,to_date('03/31/2023','mm/dd/yyyy') ,x.product_type);
            L_LINE := X.ACC_NUM ||',' ||l_balance||',"'||l_employer_name||'",'||x.product_type;
             UTL_FILE.PUT_LINE( FILE   => L_UTL_ID,   BUFFER => L_LINE );
   end loop;

   UTL_FILE.FCLOSE(FILE => L_UTL_ID);


    IF FILE_EXISTS(L_FILE_NAME,'MAILER_DIR') = 'TRUE' THEN
                    mail_utility.send_file_in_emails(p_from_email => 'oracle@sterlingadministration.com'
                                              ,  p_to_email  => 'raghavendra.joshi@sterlingadministration.com, shavee.kapoor@sterlingadministration.com'
                                              ,  p_file_name => l_file_name
                                              ,  p_sql       => null
                                              ,  p_html_message => null
                                              ,  p_report_title => 'HRA FSA Balance Report for 03/31/2023');
    END IF;


   END HRA_FSA_Emp_Bal_report_03312023;

-- Added by Joshi for 12139.
PROCEDURE SEND_REQ_TO_ADD_REMITT_BANK(P_ACC_Id NUMBER,P_ENTITY_TYPE VARCHAR2, P_ENTITY_ID IN NUMBER, X_NOTIFICATION_ID OUT NUMBER)
IS
l_notify_id NUMBER;
l_primary_email  varchar2(2000);
l_Acc_num varchar2(50);
l_entity_name varchar2(250);
l_url   varchar2(2000);
l_entrp_id number;
l_name varchar2(250);
l_entrp_code   VARCHAR2(20) ;
BEGIN
     FOR X IN ( SELECT a.template_subject
                                    ,a.template_body
                                    ,a.to_address
                                    ,a.cc_address
                          FROM NOTIFICATION_TEMPLATE A
                        WHERE NOTIFICATION_TYPE = 'EXTERNAL'
                             AND TEMPLATE_NAME = 'ER_REMITTANCE_BANK_ADD_REQUEST'
                             AND STATUS = 'A')
       LOOP

            FOR ACC IN ( SELECT A.ACC_NUM , A.ENTRP_ID, E.NAME, E.ENTRP_CODE
                                      FROM ACCOUNT A, ENTERPRISE E
                                    WHERE A.ACC_ID = P_ACC_ID
                                         AND A.ENTRP_ID = E.ENTRP_ID) 
            LOOP
                l_Acc_num := ACC.ACC_NUM;
                l_entrp_id :=  ACC.ENTRP_ID;
                l_name      :=  ACC.NAME;
                l_entrp_code := ACC.ENTRP_CODE;
            END LOOP;	

            -- get the broker/GA name
            -- get the broker/GA name
            IF P_ENTITY_TYPE = 'BROKER' THEN
               l_entity_name :=  'Broker ' || pc_broker.get_broker_name(p_entity_id);
            ELSE
               l_entity_name := 'General Agent '|| pc_general_agent.get_ga_name(p_entity_id);
            END IF;

            -- get the primary email list.
            FOR smail IN (   SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  primery_email
                                            FROM ( select distinct email
                                                            FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(l_entrp_code,'PRIMARY'))  
                                                            where account_Type = 'COBRA' ) ) 
            LOOP
                l_primary_email := smail.primery_email;
            END LOOP;

            /*
            IF USER = 'SAM'  THEN
                l_url := ' <a href="https://www.sterlinghsa.com/COBRA/Employers/BankAccount">click here </a>' ;
            ELSIF USER = 'SAMQA'  THEN
                l_url :=  '<a href="https://qa.sterlinghsa.com/COBRA/Employers/BankAccount">click here </a> ';
            ELSE
                l_url := '<a href="https://dev.sterlinghsa.com/COBRA/Employers/BankAccount">click here </a>' ;
            END IF;
            */

            IF l_primary_email is not NULL THEN

                    PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                   (P_FROM_ADDRESS    => 'customer.service@sterlingadministration.com'
                   ,P_TO_ADDRESS      => l_primary_email
                   ,P_CC_ADDRESS      => x.cc_address
                   ,P_SUBJECT         => x.template_subject
                   ,P_MESSAGE_BODY    => x.template_body
                   ,P_USER_ID         => 0
                   ,P_ACC_ID          => NULL
                   ,P_TEMPLATE_NAME   => 'ER_REMITTANCE_BANK_ADD_REQUEST'
                   ,X_NOTIFICATION_ID => l_notify_id );

                   PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NUM',l_Acc_num,l_notify_id);
                   PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NAME',l_name,l_notify_id);
                   PC_NOTIFICATIONS.SET_TOKEN ('BR_GA_NAME',l_entity_name,l_notify_id);
              --     PC_NOTIFICATIONS.SET_TOKEN ('manage_payment_link_page',l_url ,l_notify_id);

               UPDATE EMAIL_NOTIFICATIONS
                      SET    MAIL_STATUS = 'READY'
                 WHERE  NOTIFICATION_ID  = l_notify_id;
            END IF;
            X_NOTIFICATION_ID :=  l_notify_id;
        END LOOP;

   EXCEPTION
       WHEN OTHERS THEN
           pc_log.log_error('PC_NOTIFICATIONS.SEND_REQ_TO_ADD_REMITT_BANK',sqlerrm);
END SEND_REQ_TO_ADD_REMITT_BANK ;

 -- Added by swamy on  01/07/2024 for 12247
PROCEDURE BANK_EMAIL_NOTIFICATIONS
   (p_bank_acct_id    IN NUMBER
   ,p_bank_status     IN VARCHAR2
   ,p_entity_type     IN VARCHAR2
   ,p_entity_id       IN NUMBER
   ,p_denial_reason   IN  VARCHAR2
   ,p_user_id         IN NUMBER
   ,x_notification_id OUT NUMBER)
IS
l_notify_id         NUMBER;
l_acc_num           VARCHAR2(50);
l_entity_name       VARCHAR2(250);
l_url               VARCHAR2(2000);
l_entrp_id          NUMBER;
l_name              VARCHAR2(2000);
l_entrp_code        VARCHAR2(250);
l_superadmin_email  VARCHAR2(2000);
l_to_address        VARCHAR2(2000);
l_cc_address        VARCHAR2(2000);
l_notif_id          NUMBER;
l_acc_id            NUMBER;
l_user_type         VARCHAR2(10);
l_template_name     VARCHAR2(50);
l_template_subject  VARCHAR2(500);
l_denial_reason     VARCHAR2(500);
l_broker_lic        VARCHAR2(500);
num_tbl             number_tbl;      --Added by Swamy for Ticket#12681
l_ga_lic            VARCHAR2(500);
BEGIN 

	FOR n IN (SELECT entrp_id 
				FROM account
			   WHERE acc_id = p_entity_id) LOOP
	  l_entrp_id := n.entrp_id;     
	END LOOP;
pc_log.log_error(' pc notification p_entity_type',p_entity_type||' user :='||user||'p_entity_id'||p_entity_id);
	IF p_entity_type = 'ACCOUNT' THEN
	 IF NVL(l_entrp_id,0) <> 0 THEN
		FOR j IN (SELECT e.name
						,REPLACE(e.entrp_code,'-') entrp_code
						,a.acc_id
						,a.acc_num 
					FROM enterprise e,account a 
				   WHERE e.entrp_id = a.entrp_id 
					 AND a.acc_id = p_entity_id) LOOP
		  l_entrp_code := j.entrp_code;
		  l_acc_id     := j.acc_id;
		  l_name       := j.name;
		  l_acc_num    := j.acc_num;
		END LOOP;
		l_user_type := 'E';		
	   -- For ER email get Super Admin contacts
	   l_superadmin_email := PC_CONTACT.GET_SUPER_ADMIN_EMAIL(l_entrp_code);

	 ELSE
		FOR j IN (SELECT REPLACE(p.ssn,'-') ssn
						,(p.first_name||' '||p.last_name) name
						,a.acc_id
						,a.acc_num 
					FROM person p,account a 
				   WHERE p.pers_id = a.pers_id 
					 AND a.acc_id  = p_entity_id) LOOP
		  l_entrp_code := j.ssn;
		  l_acc_id     := j.acc_id;
		  l_name       := j.name;
		  l_acc_num    := j.acc_num;
		END LOOP;
		l_user_type := 'S';
        l_superadmin_email := pc_users.get_email_from_taxid(l_entrp_code);		
	 END IF;
	ELSIF p_entity_type = 'BROKER' THEN
		FOR j IN (SELECT b.broker_lic
						,b.agency_name name
						,b.broker_id
					FROM broker b 
				   WHERE broker_id = p_entity_id 
                   ) LOOP
		  l_broker_lic := j.broker_lic;
		  l_acc_id     := j.broker_id;
		  l_name       := pc_broker.get_broker_name(p_entity_id); --j.name;
		  l_acc_num    := l_name;--j.name;
		END LOOP;
		l_user_type := 'B';
        l_superadmin_email := PC_CONTACT.GET_SUPER_ADMIN_EMAIL(l_broker_lic);   
        pc_log.log_error(' pc notification l_superadmin_email',l_superadmin_email||' l_broker_lic :='||l_broker_lic||'l_acc_id'||l_acc_id);
	ELSIF p_entity_type = 'GA' THEN
		FOR j IN (SELECT g.ga_lic
						,g.agency_name name
						,g.ga_id
					FROM general_agent g 
				   WHERE ga_id = p_entity_id 
                   ) LOOP
		  l_ga_lic     := j.ga_lic;
		  l_acc_id     := j.ga_id;
		  l_name       := j.name;
		  l_acc_num    := j.name;
		END LOOP;
		l_user_type := 'B';
        l_superadmin_email := trim(PC_CONTACT.GET_SUPER_ADMIN_EMAIL(l_ga_lic));   
	END IF;

    pc_log.log_error(' pc notification l_entrp_code',l_entrp_code||' l_user_type :='||l_user_type||'l_superadmin_email'||l_superadmin_email);

    IF USER NOT IN ('SAM','APEX_PUBLIC_USER') THEN   -- remove samqa
       l_to_address := 'IT-Team@sterlingadministration.com';
      -- l_cc_address := 'verification.department@sterlingadministration.com'; -- uncomment
    ELSE
     --  l_to_address := l_superadmin_email;
     --  l_cc_address := 'verification.department@sterlingadministration.com';  -- uncomment
       l_to_address := 'IT-Team@sterlingadministration.com';
       l_cc_address := NULL;  -- uncomment

    END IF;

   pc_log.log_error(' pc notification p_bank_status',p_bank_status||' L_TO_ADDRESS :='||L_TO_ADDRESS);

    IF L_TO_ADDRESS IS NOT NULL THEN
        -- Active bank status
        IF p_bank_status = 'A' THEN
           l_template_name :=  'ACTIVE_BANK_EMAIL_NOTIFICATIONS';           
        -- Pending Documentation Bank status
        ELSIF p_bank_status = 'P' THEN
           l_template_name :=  'VERIFICATION_FAILURE_BANK_EMAIL_NOTIFICATIONS';      
        -- Inactive Bank status
        ELSE
           l_template_name := 'INACTIVE_BANK_EMAIL_NOTIFICATIONS';
        END IF;

        pc_log.log_error(' pc notification l_template_name',l_template_name);

        FOR X IN ( SELECT a.template_subject
                             ,a.template_body
                             ,a.cc_address
                        FROM notification_template A
                       WHERE notification_type = 'EXTERNAL'
                         AND template_name     = l_template_name 
                         AND STATUS = 'A')
            LOOP

                l_template_subject := x.template_subject||' '||l_acc_num;

                PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                                  (p_from_address    => 'no-reply@sterlingadministration.com'
                                  ,p_to_address      => l_to_address  
                                  ,p_cc_address      => l_cc_address 
                                  ,p_subject         => l_template_subject
                                  ,p_message_body    => x.template_body
                                  ,p_acc_id          => l_acc_id
                                  ,p_user_id         => p_user_id
                                  ,x_notification_id => l_notif_id );

                   pc_log.log_error(' pc notification p_DENIAL_REASON',p_DENIAL_REASON);
                   l_denial_reason := pc_lookups.GET_meaning(P_LOOKUP_CODE => p_DENIAL_REASON,P_LOOKUP_NAME => 'GIACT_BANK_REASON');
                   PC_NOTIFICATIONS.SET_TOKEN ('NAME',l_name,l_notif_id);
                   PC_NOTIFICATIONS.SET_TOKEN ('DENIAL_REASON',l_denial_reason,l_notif_id);   -- Added for Ticket#12397

                    UPDATE EMAIL_NOTIFICATIONS
                       SET MAIL_STATUS = 'READY'
                          ,ACC_ID      = l_acc_id
                          ,event       = l_template_name
                     WHERE NOTIFICATION_ID  = l_notif_id;

                num_tbl(1) := p_user_id;     --Added by Swamy for Ticket#12681
                pc_notifications.add_notify_users(num_tbl,l_notif_id);    --Added by Swamy for Ticket#12681
            END LOOP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	     pc_log.log_error('PC_NOTIFICATIONS.BANK_EMAIL_NOTIFICATIONS',sqlerrm||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
END BANK_EMAIL_NOTIFICATIONS;

-- Added by Swamy for Ticket#12361 21/11/2024
-- Mail should trigger to primary,broker and compliance team when send mail is clicked from SAM service documents of the employer.
-- Only for POP the latest ben plan rto docs is considered to send the mail.
PROCEDURE RTO_POP_EMAIL_NOTIFICATIONS
   ( p_entrp_id           IN NUMBER
    ,p_entity_name        IN VARCHAR2  
    ,p_attachment_id      IN NUMBER
    ,p_user_id            IN NUMBER
    ,x_notification_id   OUT NUMBER)
IS
l_acc_num           VARCHAR2(50);
l_name              VARCHAR2(250);
l_entrp_code        VARCHAR2(250);
l_superadmin_email  VARCHAR2(4000);
l_to_address        VARCHAR2(4000);
l_cc_address        VARCHAR2(4000);
l_notif_id          NUMBER;
l_acc_id            NUMBER;
l_user_type         VARCHAR2(10);
l_template_name     VARCHAR2(4000);
l_template_subject  VARCHAR2(4000);
l_primary_email     VARCHAR2(4000);
l_broker_email      VARCHAR2(4000);
l_compliance_email  VARCHAR2(4000);
l_plan_type         VARCHAR2(500);
l_plan_start_date   VARCHAR2(500);
l_plan_name         VARCHAR2(500);
l_subject_year      VARCHAR2(250);
l_length            NUMBER;
l_notif_exist       NUMBER;
BEGIN 



    pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS p_entrp_id ',p_entrp_id||' p_entity_name :='||p_entity_name||' p_user_id :='||p_user_id||' p_attachment_id :='||p_attachment_id);
	IF NVL(p_entrp_id,0) <> 0 THEN
		FOR j IN (SELECT e.name
						,REPLACE(e.entrp_code,'-') entrp_code
						,a.acc_id
						,a.acc_num 
					FROM enterprise e,account a 
				   WHERE e.entrp_id = a.entrp_id 
					 AND a.entrp_id = p_entrp_id) 
		LOOP
		  l_entrp_code := j.entrp_code;
		  l_acc_id     := j.acc_id;
		  l_name       := j.name;
		  l_acc_num    := j.acc_num;
		END LOOP;

		l_user_type := 'E';	

        pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS l_acc_id ',l_acc_id);

		FOR k IN (SELECT UPPER(document_name) document_name,document_purpose,description 
                    FROM file_attachments 
                   WHERE attachment_id = p_attachment_id 
                     AND NVL(rto_plan_doc_sent_by,'*') = '*') 
		LOOP
			IF UPPER(k.document_purpose) like  '%PLAN_DOC%'  THEN
                  l_plan_name := k.document_name;
                  -- Document name will be generated in the format of Employername-planname-year.pdf. so taking the last 7 digits which would be 2024.pdf.
                  -- in order to take the year, we take entire length -7 and substr of length ,4.
                  l_length := LENGTH(TRIM(l_plan_name)) -7;
                  l_subject_year := SUBSTR(l_plan_name,l_length,4);

                  IF INSTR(UPPER(l_plan_name),'CAFETERIA') > 0 THEN  
                     l_plan_name := 'Cafeteria Plan Documents';
                     l_template_name := 'RTO_POP_CAFETERIA_PLAN_EMAIL_TEMPLATE';
                  ElSIF INSTR(UPPER(l_plan_name),'PREMIUM') > 0 THEN 
                     l_plan_name := 'Premium Only Plan Documents';
                     l_template_name := 'RTO_POP_BASIC_EMAIL_TEMPLATE';
                  END IF;
            END IF;

			pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS k.document_name ',k.document_name||' k.document_purpose :='||k.document_purpose||' k.description :='||k.description); 
			pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS l_plan_name ',l_plan_name||' l_length :='||l_length||' l_subject_year :='||l_subject_year||' l_plan_name :='||l_plan_name); 


			-- For ER email get Primary contacts
			l_primary_email := NULL;

			SELECT  LISTAGG(email, ',') WITHIN GROUP (ORDER BY email)  INTO l_primary_email
			FROM ( SELECT DISTINCT email
			FROM TABLE(pc_contact.get_contact_info(l_entrp_code,'PRIMARY')));	

			-- CC should be broker/supar admin/complance team.
			SELECT  LISTAGG(EMAIL, ',') WITHIN GROUP (ORDER BY EMAIL)  INTO l_cc_address
			FROM ( SELECT distinct email
                           FROM TABLE(PC_CONTACT.GET_CONTACT_INFO(l_entrp_code,'BROKER'))
                          UNION
                          SELECT PC_CONTACT.GET_SUPER_ADMIN_EMAIL(l_entrp_code) email   from dual
                          UNION
                          SELECT 'compliance@sterlingadministration.com'  email from dual  );

			-- pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS l_primary_email ',l_primary_email||' l_broker_email :='||l_broker_email||' l_compliance_email :='||l_compliance_email);
			pc_log.log_error(' pc notification l_entrp_code',l_entrp_code||' l_user_type :='||l_user_type||'l_superadmin_email'||l_superadmin_email||' USER :='||USER);

			IF USER NOT IN ('SAM','APEX_PUBLIC_USER') THEN  
				l_to_address := 'IT-Team@sterlingadministration.com';
				l_cc_address := NULL;
			ELSE
                l_to_address := 'IT-Team@sterlingadministration.com';
                l_cc_address := NULL;
				--l_to_address := l_primary_email;
				--l_cc_address:=  l_superadmin_email||','||l_compliance_email;   
			END IF;

			pc_log.log_error(' pc notification.RTO_POP_EMAIL_NOTIFICATIONS p_entity_name',p_entity_name||' L_TO_ADDRESS :='||L_TO_ADDRESS);

			IF L_TO_ADDRESS IS NOT NULL THEN

				pc_log.log_error(' pc notification.RTO_POP_EMAIL_NOTIFICATIONS l_template_name',l_template_name);
				FOR X IN ( SELECT a.template_subject
								 ,a.template_body
								 ,a.cc_address
							FROM notification_template A
						   WHERE notification_type = 'EXTERNAL'
							 AND template_name     = l_template_name 
							 AND STATUS = 'A')
				LOOP

				   FOR j IN (SELECT count(*) cnt
						   FROM email_notifications 
						  WHERE mail_status IN ('SENT','READY')
							AND TRUNC(creation_date) = TRUNC(sysdate)
							AND acc_id = l_Acc_id
							AND event = l_template_name) LOOP
					l_notif_exist :=  j.cnt;    
                    END LOOP;

                    pc_log.log_error(' pc notification.RTO_POP_EMAIL_NOTIFICATIONS l_template_name',l_template_name||' l_notif_exist :='||l_notif_exist); 
                    IF NVL(l_notif_exist,0) = 0 THEN
                        l_template_subject := l_name||' '||l_plan_name||' - '||l_subject_year||' ('||l_acc_num||')';

                        PC_NOTIFICATIONS.INSERT_NOTIFICATIONS
                                          (p_from_address    => 'compliance@sterlingadministration.com'
                                          ,p_to_address      => l_to_address  
                                          ,p_cc_address      => l_cc_address 
                                          ,p_subject         => l_template_subject
                                          ,p_message_body    => x.template_body
                                          ,p_acc_id          => l_acc_id
                                          ,p_user_id         => p_user_id
                                          ,x_notification_id => l_notif_id );

                        PC_NOTIFICATIONS.SET_TOKEN ('NAME',l_name,l_notif_id);

                        UPDATE EMAIL_NOTIFICATIONS
                           SET MAIL_STATUS = 'READY'
                              ,ACC_ID      = l_acc_id
                              ,event       = l_template_name
							  ,attachment_id = p_attachment_id  -- Added by swamy for Ticket#12665
                         WHERE NOTIFICATION_ID  = l_notif_id;

                         UPDATE file_attachments
                            SET rto_plan_doc_sent_by = p_user_id
                               ,rto_plan_doc_sent_date = sysdate
                               ,show_online = 'Y'
                         WHERE attachment_id = p_attachment_id;
                    END IF;     
			     END LOOP;
             END IF;
        END LOOP;
    END IF;
    pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS l_notif_id ',l_notif_id);
EXCEPTION
    WHEN OTHERS THEN
	     pc_log.log_error('PC_NOTIFICATIONS.RTO_POP_EMAIL_NOTIFICATIONS Others error ',sqlerrm);
END RTO_POP_EMAIL_NOTIFICATIONS;

--Added by Joshi for 12621
PROCEDURE ER_ADD_REMITT_BANK_NOTIIFICATION
IS
L_NOTIFICATION_ID NUMBER;
BEGIN
	FOR X IN ( SELECT ERR.ER_REMITT_BANK_NOTIF_ID, ERR.ACC_ID, ERR.ENTITY_TYPE, ERR.ENTITY_ID
                         FROM ACCOUNT A, ER_ADD_REMITT_BANK_NOTIFICATION ERR
                       WHERE A.ACC_ID= ERR.ACC_ID
                            AND A.ACCOUNT_STATUS = 1
                            AND NVL(ERR.PROCESS_STATUS,'N') = 'N' 
			 )
	LOOP
            L_NOTIFICATION_ID  := NULL;    
            pc_log.log_error('PC_NOTIFICATIONS.ER_ADD_REMITT_BANK_NOTIIFICATION X.ACC_ID  ',X.ACC_ID);
            pc_log.log_error('PC_NOTIFICATIONS.ER_ADD_REMITT_BANK_NOTIIFICATION X.ENTITY_TYPE  ',X.ENTITY_TYPE);
            pc_log.log_error('PC_NOTIFICATIONS.ER_ADD_REMITT_BANK_NOTIIFICATION X.ENTITY_ID  ',X.ENTITY_ID); 

			PC_NOTIFICATIONS.SEND_REQ_TO_ADD_REMITT_BANK(P_ACC_ID 			    => X.ACC_ID
                                                                                           ,P_ENTITY_TYPE 		    => X.ENTITY_TYPE
                                                                                           ,P_ENTITY_ID 	        	=> X.ENTITY_ID
                                                                                           ,X_NOTIFICATION_ID 	=> L_NOTIFICATION_ID ) ;

			pc_log.log_error('PC_NOTIFICATIONS.ER_ADD_REMITT_BANK_NOTIIFICATION L_NOTIFICATION_ID  ',L_NOTIFICATION_ID); 		

			IF L_NOTIFICATION_ID IS NOT NULL THEN

				UPDATE ER_ADD_REMITT_BANK_NOTIFICATION
                	   SET PROCESS_STATUS 	= 'P',
                        	  NOTIFICATION_ID  = L_NOTIFICATION_ID,
                              MAILED_DATE = SYSDATE
				 WHERE ER_REMITT_BANK_NOTIF_ID = X.ER_REMITT_BANK_NOTIF_ID; 	 
			END IF;

	END LOOP;
END;


END pc_notifications;
/

