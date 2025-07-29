create or replace procedure samqa.generate_ach_upload (
    x_file_name out varchar2
) as

    g_destination      constant varchar2(30) := '122234149';
    g_origin           constant varchar2(30) := '122234149';
    g_dest_bank        constant varchar2(30) := 'FEDERAL RESERVE';
    g_bank_name        constant varchar2(30) := 'CITIZENS BUSINESS BANK';
    g_company_name     constant varchar2(30) := 'STERLING HEALTH';
    g_data             constant varchar2(30) := 'ONLINE PAY'
                                    || to_char(sysdate - 1, 'YYYY-MM-DD');
    g_taxid            constant varchar2(30) := '84-1637046';
    g_transaction_type constant varchar2(30) := 'ACH_TRANST';
    g_service_class    constant varchar2(30) := '200';  -- ACH Entries Mixed Debits and Credits
    g_standard_entry   constant varchar2(30) := 'PPD';  -- Pre arranged payment and deposit entries
    l_batch_number     number;
    l_file_header      varchar2(94);
    l_batch_header     varchar2(150);
    l_ccd_record       varchar2(94);
    l_line_count       number := 0;
    l_file_control     varchar2(94);
    l_batch_control    varchar2(96);
    l_file_end         varchar2(94);
    l_entry_count      number;
    l_debit_amount     number := 0;
    l_credit_amount    number := 0;
    l_entry_hash       number := 0;
    l_total_amount     number := 0;
    l_utl_id           utl_file.file_type;
    l_file_name        varchar2(3200);
begin
    l_batch_number := pc_debit_card.insert_file_seq('ACH_FILE');
    l_file_name := 'TEST_ACH_'
                   || l_batch_number
                   || '.txt';
    x_file_name := l_file_name;
    l_utl_id := utl_file.fopen('BANK_SERV_DIR', l_file_name, 'w');
    l_file_header := '101 '
                     || rpad(g_destination, 9, ' ')
                     || lpad(g_taxid, 10, '0')
                     || to_char(sysdate, 'YYMMDD')
                     || to_char(sysdate, 'HHMM')
                     || 'A'
                     || '094'
                     || '10'
                     || '1'
                     || rpad(g_dest_bank, 23, ' ')
                     || rpad(g_bank_name, 23, ' ')
                     || '        ';

    dbms_output.put_line('header '
                         || l_file_header
                         || ', length of file header '
                         || length(l_file_header));

    utl_file.put_line(
        file   => l_utl_id,
        buffer => l_file_header
    );
    l_batch_header := '5'
                      || g_service_class
                      || rpad(g_company_name, 16, ' ')
                      || rpad(g_data, 20, ' ')
                      || g_taxid
                      || 'CCD'
                      || g_transaction_type
                      || to_char(sysdate, 'YYMMDD')
                      || to_char(sysdate, 'YYMMDD')
                      || rpad(' ', 3, ' ')
                      || '1'
                      || substr(g_destination, 1, 8)
                      || lpad(l_batch_number, 7, '0');

    dbms_output.put_line('batch header '
                         || l_batch_header
                         || ', length of batch header '
                         || length(l_batch_header));

    utl_file.put_line(
        file   => l_utl_id,
        buffer => l_batch_header
    );
    l_entry_count := 0;
    l_debit_amount := 0;
    l_credit_amount := 0;
    for x in (
        select
            substr(bank_routing_num, 1, 8) receiving_dfi_num,
            substr(bank_routing_num, 9, 1) check_digit,
            substr(bank_routing_num, 1, 8) routing_num,
            rpad(bank_acct_num, 17, ' ')   account_number,
            replace(
                replace(
                    to_char(amount, '9999999.99'),
                    '.',
                    ''
                ),
                ' ',
                '0'
            )                              total_amount,
            case
                when transaction_type = 'C' then
                    decode(bank_acct_type, 'C', 22, 32)
                when transaction_type = 'D' then
                    decode(bank_acct_type, 'C', 27, 37)
            end                            transaction_code,
            amount,
            transaction_type,
            substr(
                lpad(personfname || nvl(personlname, ''),
                     22,
                     ' '),
                1,
                22
            )                              name,
            lpad(transaction_id, 15, ' ')  transaction_id,
            lpad(acc_num, 15, ' ')         acc_num
        from
            ach_nacha_v
        where
            status in ( 1, 2 )
            and trunc(transaction_date) >= sysdate + 1
            and amount > 0
            and rownum < 15
    ) loop
        l_ccd_record := '6';
        l_line_count := l_line_count + 1;
        l_ccd_record := l_ccd_record
                        || x.transaction_code
                        || x.receiving_dfi_num
                        || x.check_digit
                        || x.account_number
                        || replace(x.total_amount, '.')
                        || x.transaction_id
                        || x.name
                        || '  '
                        || '0'
                        || substr(g_origin, 1, 8)
                        || lpad(l_line_count, 7, '0');
  --    IF x.transaction_type = 'C' THEN
        l_debit_amount := l_debit_amount + nvl(x.amount, 0);
    --  ELSE
        l_credit_amount := l_credit_amount + nvl(x.amount, 0);
    --  END IF;
        l_entry_count := l_entry_count + 1;
        l_entry_hash := l_entry_hash + x.receiving_dfi_num;
        dbms_output.put_line(' ccd record '
                             || l_ccd_record
                             || ', LENGTH OF CCD '
                             || length(l_ccd_record));

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_ccd_record
        );
    -- Credit
        l_line_count := l_line_count + 1;
        l_ccd_record := '6';
        l_ccd_record := l_ccd_record
                        || 27
                        || substr(g_origin, 1, 8)
                        || substr(g_origin, 9, 1)
                        || x.account_number
                        || replace(x.total_amount, '.')
                        || x.transaction_id
                        || x.name
                        || '  '
                        || '0'
                        || substr(g_origin, 1, 8)
                        || lpad(l_line_count, 7, '0');

        l_entry_count := l_entry_count + 1;
        l_entry_hash := l_entry_hash + substr(g_origin, 1, 8);
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_ccd_record
        );
    end loop;

    dbms_output.put_line(' ccd record '
                         || l_ccd_record
                         || ', LENGTH OF CCD '
                         || length(l_ccd_record));

    dbms_output.put_line('  l_debit_amount ' || l_debit_amount);
    l_batch_control := '8'
                       || g_service_class
                       || lpad(l_entry_count, 6, '0')
                       || lpad(l_entry_hash, 10, '0')
                       || lpad(
        replace(
            replace(
                to_char(l_debit_amount, '9999999.99'),
                '.'
            ),
            ' '
        ),
        12,
        '0'
    )
                       || lpad(
        replace(
            replace(
                to_char(l_credit_amount, '9999999.99'),
                '.'
            ),
            ' '
        ),
        12,
        '0'
    )
                       || g_taxid
                       || lpad(' ', 25, ' ')
                       || substr(g_destination, 1, 8)
                       || lpad(l_batch_number, 7, '0');

    utl_file.put_line(
        file   => l_utl_id,
        buffer => l_batch_control
    );
    dbms_output.put_line('batch control '
                         || l_batch_control
                         || ', length of batch header '
                         || length(l_batch_control));

    l_file_control := '9'
                      || lpad(1, 6, '0')
                      || lpad(1, 6, '0')
                      || lpad(l_line_count, 8, '0')
                      || lpad(l_entry_hash, 10, '0')
                      || lpad(
        replace(
            replace(
                to_char(l_debit_amount, '9999999.99'),
                '.'
            ),
            ' '
        ),
        12,
        '0'
    )
                      || lpad(
        replace(
            replace(
                to_char(l_credit_amount, '9999999.99'),
                '.'
            ),
            ' '
        ),
        12,
        '0'
    )
                      || lpad(' ', 39, ' ');

    utl_file.put_line(
        file   => l_utl_id,
        buffer => l_file_control
    );
    l_file_end := '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';
    utl_file.put_line(
        file   => l_utl_id,
        buffer => l_file_end
    );
    utl_file.fclose(file => l_utl_id);
    dbms_output.put_line(' file control '
                         || l_file_control
                         || length(l_file_control));
end generate_ach_upload;
/


-- sqlcl_snapshot {"hash":"62ba894c146ee79de12ecc3f7e3a5807e569ec95","type":"PROCEDURE","name":"GENERATE_ACH_UPLOAD","schemaName":"SAMQA","sxml":""}