# what:
#
#   generates a comby command line to "instrument" janet c source code
#   to help ascertain code paths
#
#   WARNING:
#
#     this is likely to change source code, so make sure appropriate
#     backups / commits / stashes have been made

# example of target command to generate:

``
comby \
  -in-place \
  -matcher .c \
  -d ./src \
  -rule \
  'where match :[name] { | "janetc_array" -> true | "janetc_maker" -> true }' \
  ':[[name]](:[params]) {:[hole]}' \
  ':[[name]](:[params]) {fprintf(stderr, ":[[name]]\n");:[hole]}'
``

# prerequisites:
#
# -janet
# -comby

# how to use:
#
# -find some c function names in janet c source code, then populate
#  fnames.txt appropriately (one function name per line; see example file)
#
# -generate the comby command by running this file via janet
#
# -in a clean checkout of janet's repository root, run the generated command
#
# -build janet and start newly built repl:
#
#    make clean && make && ./build/janet
#
# -type away at the janet repl to see evidence of functions being called.
#
# -git reset --hard to restore source code to pristine state

(def comby-template
``
 comby \
   -in-place \
   -matcher .c \
   -d ./src \
   -rule \
   'where match :[name] { $MATCH_CLAUSES }' \
   ':[[name]](:[params]) {:[hole]}' \
   ':[[name]](:[params]) {fprintf(stderr, ":[[name]]\n");:[hole]}'
``)

(def fnames
  (when (os/stat "fnames.txt")
    (->> (string/split "\n" (slurp "fnames.txt"))
         (filter |(< 0 (length $))))))

(defn make-match-clause
  [fname]
  (string "| \"" fname "\" -> true"))

(when fnames
  (print (string/replace "$MATCH_CLAUSES"
                         (string/join (map make-match-clause
                                           fnames)
                                      " ")
                         comby-template)))
