-- liquibase formatted sql
-- changeset SAMQA:1754374139927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_receivable.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_receivable.sql:null:0649bf195b5504d92ee66b40806d81e1fa484834:create

create or replace package samqa.pc_receivable as

/*  PROCEDURE   INSERT_RECEIVABLE_BATCH (P_BATCH_NUMBER  IN VARCHAR2
                                      ,P_SOURCE_SYSTEM IN VARCHAR2
                                      ,P_SOURCE_TYPE   IN VARCHAR2
                                      ,P_AMOUNT        IN NUMBER
                                      ,P_STATUS        IN VARCHAR2
                                      ,P_START_DATE    IN DATE
                                      ,P_END_DATE      IN DATE
                                      ,P_USER_ID       IN NUMBER
                                      ,X_RECEIVABLE_BATCH_ID OUT NUMBER);

  PROCEDURE UPDATE_RECEIVABLE_BATCH(P_BATCH_NUMBER IN VARCHAR2
                                   ,P_STATUS       IN VARCHAR2
                                   ,P_USER_ID      IN NUMBER);

  PROCEDURE PROCESS_REBATE_BATCH (P_BATCH_NUMBER IN VARCHAR2
                                 ,P_USER_ID      IN NUMBER);
*/
    procedure process_invoice_batch (
        p_batch_number in varchar2,
        p_user_id      in number
    );

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
    );

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
    );

/*  PROCEDURE UPDATE_APPLIED_AMOUNT(P_RECEIVABLE_ID  IN NUMBER
                                 ,P_BATCH_NUMBER   IN NUMBER
                                 ,P_AMOUNT_APPLIED IN NUMBER
                                 ,P_NOTE           IN VARCHAR2
                                 ,P_USER_ID        IN NUMBER
                                 ,P_PAYMENT_BATCH_ID IN NUMBER);
*/
/* PROCEDURE POST_REBATE_BATCH(P_BATCH_NUMBER   IN NUMBER
                            ,P_USER_ID        IN NUMBER
                            ,P_PAYMENT_BATCH_ID IN NUMBER);
  */
  --PROCEDURE UPDATE_RECEIVABLE_BATCH_STATUS(P_BATCH_NUMBER IN VARCHAR2);

    procedure update_receivable_status (
        p_receivable_id in number,
        p_status        in varchar2,
        p_note          in varchar2,
        p_user_id       in number
    );
 /* PROCEDURE UPDATE_RECV_PAYMENT_BAL(P_PAYMENT_BATCH_ID IN NUMBER
                                   ,P_BATCH_NUMBER IN NUMBER);
  */
    procedure cancel_receivable (
        p_receivable_id in number,
        p_status        in varchar2,
        p_reason        in varchar2,
        p_user_id       in number
    );

    procedure cancel_receivable_line (
        p_receivable_line_id in number,
        p_status             in varchar2,
        p_amount             in number,
        p_reason             in varchar2,
        p_user_id            in number
    );

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
    );
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
                            ,P_NOTE                                    VARCHAR2);

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
    );

    function get_receivable_entity_type (
        p_receivable_id in number
    ) return varchar2;

    function calc_remaining_amt (
        p_check_amt     in number,
        p_returned_amt  in number,
        p_cancelled_amt in number
    ) return number;

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
    );

end;
/

