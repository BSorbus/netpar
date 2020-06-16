class RefactorPnaIndex < ActiveRecord::Migration
  def up
    remove_index :teryt_pna_codes, :woj
    remove_index :teryt_pna_codes, :woj_nazwa
    remove_index :teryt_pna_codes, :pow
    remove_index :teryt_pna_codes, :pow_nazwa
    remove_index :teryt_pna_codes, :gmi
    remove_index :teryt_pna_codes, :gmi_nazwa
    remove_index :teryt_pna_codes, :sym
    remove_index :teryt_pna_codes, :sym_nazwa
    remove_index :teryt_pna_codes, :sympod
    remove_index :teryt_pna_codes, :sympod_nazwa
    remove_index :teryt_pna_codes, :mie_nazwa
    remove_index :teryt_pna_codes, :uli_nazwa
    remove_index :teryt_pna_codes, :pna
    remove_index :teryt_pna_codes, :pna_teryt #, unique: true
    remove_index :teryt_pna_codes, [:mie_nazwa, :uli_nazwa, :pna]

    add_index  :teryt_pna_codes, :woj_nazwa, name: "teryt_pna_codes_woj_nazwa_idx", using: :gin, order: {woj_nazwa: :gin_trgm_ops}
    add_index  :teryt_pna_codes, :pow_nazwa, name: "teryt_pna_codes_pow_nazwa_idx", using: :gin, order: {pow_nazwa: :gin_trgm_ops}
    add_index  :teryt_pna_codes, :gmi_nazwa, name: "teryt_pna_codes_gmi_nazwa_idx", using: :gin, order: {gmi_nazwa: :gin_trgm_ops}
    add_index  :teryt_pna_codes, :mie_nazwa, name: "teryt_pna_codes_mie_nazwa_idx", using: :gin, order: {mie_nazwa: :gin_trgm_ops}
    add_index  :teryt_pna_codes, :uli_nazwa, name: "teryt_pna_codes_uli_nazwa_idx", using: :gin, order: {uli_nazwa: :gin_trgm_ops}
    add_index  :teryt_pna_codes, :pna, 		 name: "teryt_pna_codes_pna_idx", using: :gin, order: {pna: :gin_trgm_ops}

	# CREATE INDEX customer_names_on_last_name_idx ON customer_names USING GIN(last_name gin_trgm_ops);
	# CREATE INDEX index_users_full_name ON users using gin ((first_name || ' ' || last_name) gin_trgm_ops);
	# add_index "contacts", ["first_name", "last_name", "name"], name: "contacts_search_idx", using: :gin, order: {first_name: :gin_trgm_ops, last_name: :gin_trgm_ops, name: :gin_trgm_ops}

	# add_index :teryt_pna_codes, ["pna", "mie_nazwa", "uli_nazwa", "gmi_nazwa"], name: "teryt_pna_codes_idx", 
	# 	using: :gin, order: {pna: :gin_trgm_ops, mie_nazwa: :gin_trgm_ops, uli_nazwa: :gin_trgm_ops, gmi_nazwa: :gin_trgm_ops}

	# add_index :teryt_pna_codes, [:mie_nazwa, :uli_nazwa, :woj_nazwa, :pow_nazwa, :gmi_nazwa, :pna], name: "teryt_pna_codes_idx", 
	# 	using: :gin, order: {mie_nazwa: :gin_trgm_ops, uli_nazwa: :gin_trgm_ops, woj_nazwa: :gin_trgm_ops, pow_nazwa: :gin_trgm_ops, gmi_nazwa: :gin_trgm_ops, pna: :gin_trgm_ops} 

	# add_index :teryt_pna_codes, [:mie_nazwa, :uli_nazwa, :woj_nazwa, :pow_nazwa, :gmi_nazwa, :pna], name: "teryt_pna_codes_idx", 
	# 	using: :gin, order: {mie_nazwa: :gin_trgm_ops, uli_nazwa: :gin_trgm_ops, woj_nazwa: :gin_trgm_ops, pow_nazwa: :gin_trgm_ops, gmi_nazwa: :gin_trgm_ops, pna: :gin_trgm_ops} 

	# Rails 5.2+ use opclass
	#add_index :contacts, [:first_name, :last_name, :name], name: "contacts_search_idx", using: :gin, opclass: { first_name: :gin_trgm_ops, last_name: :gin_trgm_ops, name: :gin_trgm_ops }

	# execute <<-SQL
	# 	CREATE INDEX teryt_pna_codes_idx ON teryt_pna_codes using gin ((pna || ' ' || mie_nazwa || ' ' || uli_nazwa || ' ' || gmi_nazwa) gin_trgm_ops);
	# SQL
  end

  def down
    # remove_index  :teryt_pna_codes, :woj_nazwa
    # remove_index  :teryt_pna_codes, :pow_nazwa
    # remove_index  :teryt_pna_codes, :gmi_nazwa
    # remove_index  :teryt_pna_codes, :mie_nazwa
    # remove_index  :teryt_pna_codes, :uli_nazwa
    # remove_index  :teryt_pna_codes, :pna

    remove_index :teryt_pna_codes, name: "teryt_pna_codes_woj_nazwa_idx"
    remove_index :teryt_pna_codes, name: "teryt_pna_codes_pow_nazwa_idx"
    remove_index :teryt_pna_codes, name: "teryt_pna_codes_gmi_nazwa_idx"
    remove_index :teryt_pna_codes, name: "teryt_pna_codes_mie_nazwa_idx"
    remove_index :teryt_pna_codes, name: "teryt_pna_codes_uli_nazwa_idx"
    remove_index :teryt_pna_codes, name: "teryt_pna_codes_pna_idx"

    add_index :teryt_pna_codes, :woj
    add_index :teryt_pna_codes, :woj_nazwa
    add_index :teryt_pna_codes, :pow
    add_index :teryt_pna_codes, :pow_nazwa
    add_index :teryt_pna_codes, :gmi
    add_index :teryt_pna_codes, :gmi_nazwa
    add_index :teryt_pna_codes, :sym
    add_index :teryt_pna_codes, :sym_nazwa
    add_index :teryt_pna_codes, :sympod
    add_index :teryt_pna_codes, :sympod_nazwa
    add_index :teryt_pna_codes, :mie_nazwa
    add_index :teryt_pna_codes, :uli_nazwa
    add_index :teryt_pna_codes, :pna
    add_index :teryt_pna_codes, :pna_teryt #, unique: true
    add_index :teryt_pna_codes, [:mie_nazwa, :uli_nazwa, :pna]
  end
end
