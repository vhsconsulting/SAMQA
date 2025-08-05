create or replace procedure samqa.uha_check_run_calendar as
begin
    insert into calendar_master values ( calendar_seq.nextval,
                                         'CARRIER_CLAIM_CYCLE',
                                         23067,
                                         sysdate,
                                         0,
                                         sysdate,
                                         0,
                                         null );

    insert into scheduler_master (
        scheduler_id,
        acc_id,
        payment_start_date,
        payment_end_date,
        recurring_flag,
        recurring_frequency,
        scheduler_name,
        note,
        creation_date,
        created_by,
        last_updated_date,
        last_updated_by,
        calendar_id
    ) values ( scheduler_seq.nextval,
               null,
               '01-JAN-2015',
               '31-DEC-2015',
               'Y',
               'CUSTOM',
               'CUSTOM'
               || ':'
               || to_char(to_date('01-JAN-2015'), 'MM/DD/YYYY')
               || ':'
               || to_char(to_date('31-DEC-2015'), 'MM/DD/YYYY'),
               'CUSTOM'
               || ':'
               || to_char(to_date('01-JAN-2015'), 'MM/DD/YYYY')
               || ':'
               || to_char(to_date('31-DEC-2015'), 'MM/DD/YYYY'),
               sysdate,
               0,
               sysdate,
               0,
               21 );

-- UHA claim release calendar

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '01-JAN-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '13-JAN-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '22-JAN-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '02-FEB-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '11-FEB-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '23-FEB-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '04-MAR-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '13-MAR-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '24-MAR-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '02-APR-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '13-APR-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '22-APR-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '01-MAY-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '12-MAY-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '21-MAY-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '02-JUN-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '12-JUN-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '23-JUN-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '02-JUL-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '14-JUL-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '23-JUL-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '03-AUG-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '12-AUG-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '24-AUG-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '02-SEP-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '14-SEP-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '23-SEP-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '02-OCT-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '14-OCT-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '23-OCT-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '03-NOV-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '12-NOV-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '20-NOV-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '03-DEC-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '14-DEC-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

    insert into scheduler_calendar values ( scheduler_calendar_seq.nextval,
                                            28035,
                                            '22-DEC-2015',
                                            sysdate,
                                            0,
                                            sysdate,
                                            0 );

end;
/


-- sqlcl_snapshot {"hash":"a624fdaa570e96e12627114371fe4077b9fed5af","type":"PROCEDURE","name":"UHA_CHECK_RUN_CALENDAR","schemaName":"SAMQA","sxml":""}