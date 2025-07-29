create index samqa.employer_payments_n10 on
    samqa.employer_payments (
        entrp_id,
        check_number
    );


-- sqlcl_snapshot {"hash":"f643a4cbab77fdb70be20b2446d75619312c46d9","type":"INDEX","name":"EMPLOYER_PAYMENTS_N10","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENTS_N10</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CHECK_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}