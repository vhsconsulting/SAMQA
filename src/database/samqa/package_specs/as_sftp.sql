create or replace package samqa.as_sftp is
    type tp_dir_line is record (
            file_name    varchar2(32767),
            long_name    varchar2(32767),
            is_directory boolean,
            file_size    number,
            uid          number,
            gid          number,
            perm         number,
            atime        date,
            mtime        date
    );
    type tp_dir_listing is
        table of tp_dir_line index by pls_integer;
  --
    procedure open_connection (
        i_host                 varchar2,
        i_port                 pls_integer := 22,
        i_excluded_kex_algos   varchar2 := null,
        i_preferred_kex_algos  varchar2 := null,
        i_excluded_encr_algos  varchar2 := null,
        i_preferred_encr_algos varchar2 := null,
        i_excluded_pkey_algos  varchar2 := null,
        i_preferred_pkey_algos varchar2 := null
    );

    procedure open_connection (
        i_host                 varchar2,
        i_trust_server         boolean,
        i_port                 pls_integer := 22,
        i_excluded_kex_algos   varchar2 := null,
        i_preferred_kex_algos  varchar2 := null,
        i_excluded_encr_algos  varchar2 := null,
        i_preferred_encr_algos varchar2 := null,
        i_excluded_pkey_algos  varchar2 := null,
        i_preferred_pkey_algos varchar2 := null
    );

    procedure open_connection (
        i_host                 varchar2,
        i_fingerprint          varchar2,
        i_port                 pls_integer := 22,
        i_excluded_kex_algos   varchar2 := null,
        i_preferred_kex_algos  varchar2 := null,
        i_excluded_encr_algos  varchar2 := null,
        i_preferred_encr_algos varchar2 := null,
        i_excluded_pkey_algos  varchar2 := null,
        i_preferred_pkey_algos varchar2 := null
    );

    procedure login (
        i_user       varchar2,
        i_password   varchar2 := null,
        i_priv_key   varchar2 := null,
        i_passphrase varchar2 := null,
        i_log_level  pls_integer := null
    );

    function pwd return varchar2;

    function read_dir (
        i_path varchar2
    ) return tp_dir_listing;

    function get_file (
        i_path varchar2,
        i_file in out nocopy blob
    ) return boolean;

    procedure get_file (
        i_path varchar2,
        i_file in out nocopy blob
    );

    function get_file (
        i_path      varchar2,
        i_directory varchar2,
        i_filename  varchar2
    ) return boolean;

    procedure get_file (
        i_path      varchar2,
        i_directory varchar2,
        i_filename  varchar2
    );

    function put_file (
        i_path varchar2,
        i_file blob
    ) return boolean;

    procedure put_file (
        i_path varchar2,
        i_file blob
    );

    function put_file (
        i_path      varchar2,
        i_directory varchar2,
        i_filename  varchar2
    ) return boolean;

    procedure put_file (
        i_path      varchar2,
        i_directory varchar2,
        i_filename  varchar2
    );

    procedure close_connection;

    procedure set_log_level (
        i_level pls_integer
    );

end;
/


-- sqlcl_snapshot {"hash":"9a887ba0d5b29260c368c71850b865c19131b9d0","type":"PACKAGE_SPEC","name":"AS_SFTP","schemaName":"SAMQA","sxml":""}