# TODO / Roadmap

Future bootstrap steps to add when needed. Each item maps to a new
`setup/NN_name.sh`; see `bootstrap.sh` for the numbering convention
(`<20` before deployment, `>20` after).

## 语言运行时

- [ ] **Rust / rustup** — `setup/60_rustup.sh`. Install via
      `curl ... rustup.rs | sh`. No further config needed: `00_env.fish`
      already puts `~/.cargo/bin` on PATH and `05_rustup.fish` sources
      `~/.cargo/env.fish` when present.

## 国内镜像源

- [ ] **pip** — configure a PyPI mirror (Tsinghua / Aliyun) for `pip install`.
- [ ] **cargo** — configure a crates.io mirror (rsproxy.cn / USTC) in
      `~/.cargo/config.toml`.
