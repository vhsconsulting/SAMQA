create index samqa.crm_employer_mv_n1 on
    samqa.crm_employer_mv (
        acc_num_c
    );


-- sqlcl_snapshot {"hash":"d63abd89ea0415957d0de0612e421b4c6e20d11b","type":"INDEX","name":"CRM_EMPLOYER_MV_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CRM_EMPLOYER_MV_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CRM_EMPLOYER_MV</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM_C</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}