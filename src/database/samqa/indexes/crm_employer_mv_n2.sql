create index samqa.crm_employer_mv_n2 on
    samqa.crm_employer_mv (
        acc_id_c
    );


-- sqlcl_snapshot {"hash":"bf09e52145035784d9a59062cc4c178dcf572475","type":"INDEX","name":"CRM_EMPLOYER_MV_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CRM_EMPLOYER_MV_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CRM_EMPLOYER_MV</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID_C</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}