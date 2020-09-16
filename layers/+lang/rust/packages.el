;;; packages.el --- Rust Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2020 Sylvain Benner & Contributors
;;
;; Author: Chris Hoeppner <me@mkaito.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst rust-packages
  '(
    cargo
    company
    counsel-gtags
    dap-mode
    flycheck
    (flycheck-rust :requires flycheck)
    ggtags
    helm-gtags
    ron-mode
    racer
    ;; cargo requires rust-mode but rustic needs to be loaded after rust-mode
    ;; so it can set the correct auto-mode-alist entry.
    (rustic :requires cargo)
    smartparens
    toml-mode))

(defun rust/init-cargo ()
  (use-package cargo
    :defer t
    :init
    (progn
      (spacemacs/declare-prefix-for-mode 'rustic-mode "mc" "cargo")
      (spacemacs/set-leader-keys-for-major-mode 'rustic-mode
        "c." 'cargo-process-repeat
        "ca" 'cargo-process-add
        "cA" 'cargo-process-audit
        "cc" 'cargo-process-build
        "cC" 'cargo-process-clean
        "cd" 'cargo-process-doc
        "cD" 'cargo-process-doc-open
        "ce" 'cargo-process-bench
        "cE" 'cargo-process-run-example
        "cf" 'cargo-process-fmt
        "ci" 'cargo-process-init
        "cl" 'cargo-process-clippy
        "cn" 'cargo-process-new
        "co" 'cargo-process-current-file-tests
        "cr" 'cargo-process-rm
        "cs" 'cargo-process-search
        "ct" 'cargo-process-current-test
        "cu" 'cargo-process-update
        "cU" 'cargo-process-upgrade
        "cx" 'cargo-process-run
        "cX" 'cargo-process-run-bin
        "cv" 'cargo-process-check
        "t" 'cargo-process-test))))

(defun rust/post-init-company ()
  ;; backend specific
  (spacemacs//rust-setup-company))

(defun rust/post-init-counsel-gtags ()
  (spacemacs/counsel-gtags-define-keys-for-mode 'rustic-mode))

(defun rust/pre-init-dap-mode ()
  (pcase (spacemacs//rust-backend)
    (`lsp (add-to-list 'spacemacs--dap-supported-modes 'rustic-mode)))
  (add-hook 'rustic-mode-local-vars-hook #'spacemacs//rust-setup-dap))

(defun rust/post-init-flycheck ()
  (spacemacs/enable-flycheck 'rustic-mode))

(defun rust/init-flycheck-rust ()
  (use-package flycheck-rust
    :defer t
    :init (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))

(defun rust/post-init-ggtags ()
  (add-hook 'rustic-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun rust/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'rustic-mode))

(defun rust/init-racer ()
  (use-package racer
    :defer t
    :commands racer-mode
    :config
    (progn
      (spacemacs/add-to-hook 'rustic-mode-hook '(racer-mode))
      (spacemacs/add-to-hook 'racer-mode-hook '(eldoc-mode))
      (add-to-list 'spacemacs-jump-handlers-rustic-mode 'racer-find-definition)
      (spacemacs/set-leader-keys-for-major-mode 'rustic-mode
        "hh" 'spacemacs/racer-describe)
      (spacemacs|hide-lighter racer-mode)
      (evilified-state-evilify-map racer-help-mode-map
        :mode racer-help-mode))))

(defun rust/init-rustic ()
  (use-package rustic
    :defer t
    :init
    (progn
      (spacemacs/add-to-hook 'rustic-mode-hook '(spacemacs//rust-setup-backend))

      (spacemacs/declare-prefix-for-mode 'rustic-mode "mg" "goto")
      (spacemacs/declare-prefix-for-mode 'rustic-mode "mh" "help")
      (spacemacs/declare-prefix-for-mode 'rustic-mode "mc" "cargo")
      (spacemacs/declare-prefix-for-mode 'rustic-mode "m=" "format")

      (spacemacs/set-leader-keys-for-major-mode 'rustic-mode
        "=j" 'lsp-rust-analyzer-join-lines
        "==" 'lsp-format-buffer
        "Ti" 'lsp-rust-analyzer-inlay-hints-mode
        "bD" 'lsp-rust-analyzer-status
        "bS" 'lsp-rust-analyzer-switch-server
        "gp" 'lsp-rust-analyzer-find-parent-module
        "hm" 'lsp-rust-analyzer-expand-macro
        "hs" 'lsp-rust-analyzer-syntax-tree
        "v" 'lsp-extend-selection

        "," 'lsp-rust-analyzer-rerun
        "."  'lsp-rust-analyzer-run
        ))))

(defun rust/post-init-smartparens ()
  (with-eval-after-load 'smartparens
    ;; Don't pair lifetime specifiers
    (sp-local-pair 'rustic-mode "'" nil :actions nil)))

(defun rust/init-toml-mode ()
  (use-package toml-mode
    :mode "/\\(Cargo.lock\\|\\.cargo/config\\)\\'"))

(defun rust/init-ron-mode ()
  (use-package ron-mode
    :mode ("\\.ron\\'" . ron-mode)
    :defer t))
