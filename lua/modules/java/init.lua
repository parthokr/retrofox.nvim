-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Java (nvim-jdtls — OS-aware)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("java") then return {} end

local os_util = require("retrofox.os")

local ROOT_MARKERS = {
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    "mvnw",
    "gradlew",
    ".project",
    ".git",
}

local AUGROUP = vim.api.nvim_create_augroup("RetrofoxJavaJdtls", { clear = true })
local is_java_project = vim.fs.root(vim.fn.getcwd(), ROOT_MARKERS) ~= nil

local function get_jdtls_path()
    local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    if vim.fn.isdirectory(jdtls_path) ~= 1 then
        vim.notify(
            "JDTLS is not installed yet. Open :Mason and install jdtls.",
            vim.log.levels.WARN,
            { title = "retrofox/java" }
        )
        return nil
    end
    return jdtls_path
end

local function get_jdtls_launcher(jdtls_path)
    local launcher_glob = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    if launcher_glob == "" then
        vim.notify("JDTLS equinox launcher JAR not found.", vim.log.levels.ERROR, { title = "retrofox/java" })
        return nil
    end
    return vim.split(launcher_glob, "\n")[1]
end

local function resolve_root_dir(bufnr)
    local root_dir = vim.fs.root(bufnr, ROOT_MARKERS)
    if root_dir then return root_dir end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname ~= "" then
        root_dir = vim.fs.root(bufname, ROOT_MARKERS)
        if root_dir then return root_dir end
    end

    vim.notify(
        "No Java project root found. Expected one of: " .. table.concat(ROOT_MARKERS, ", "),
        vim.log.levels.WARN,
        { title = "retrofox/java" }
    )
    return nil
end

local function workspace_dir(root_dir)
    local project_name = vim.fs.basename(root_dir)
    local project_hash = vim.fn.sha256(root_dir):sub(1, 12)
    return vim.fs.joinpath(vim.fn.stdpath("data"), "jdtls-workspace", project_name .. "-" .. project_hash)
end

local function setup_jdtls(bufnr)
    if vim.bo[bufnr].filetype ~= "java" then return end

    local jdtls = require("jdtls")
    local root_dir = resolve_root_dir(bufnr)
    if not root_dir then return end

    local jdtls_path = get_jdtls_path()
    if not jdtls_path then return end

    local launcher_jar = get_jdtls_launcher(jdtls_path)
    if not launcher_jar then return end

    local os_config = os_util.jdtls_config()
    local java_cmd = os_util.java_cmd()

    local config = {
        cmd = {
            java_cmd,
            "-javaagent:" .. jdtls_path .. "/lombok.jar",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher_jar,
            "-configuration", jdtls_path .. "/" .. os_config,
            "-data", workspace_dir(root_dir),
        },
        root_dir = root_dir,
        settings = {
            java = {
                imports = {
                    order = { "java", "javax", "jakarta", "org", "com" },
                },
                starThreshold = 5,
                staticStarThreshold = 3,
                saveActions = { organizeImports = true },
                completion = {
                    favoriteStaticMembers = {
                        "org.junit.Assert.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.mockito.Mockito.*",
                        "org.mockito.ArgumentMatchers.*",
                        "java.util.Objects.*",
                        "java.util.stream.Collectors.*",
                    },
                    importOrder = { "java", "javax", "jakarta", "org", "com" },
                },
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                    },
                    hashCodeEquals = { useJava7Objects = true, useInstanceof = true },
                    useBlocks = true,
                    generateComments = false,
                },
                sources = {
                    organizeImports = { starThreshold = 5, staticStarThreshold = 3 },
                },
                inlayHints = {
                    parameterNames = { enabled = "all" },
                },
                format = {
                    enabled = true,
                    settings = {
                        url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                        profile = "GoogleStyle",
                    },
                },
                signatureHelp = { enabled = true, description = { enabled = true } },
                contentProvider = { preferred = "fernflower" },
                referencesCodeLens = { enabled = true },
                implementationsCodeLens = { enabled = true },
            },
        },
        init_options = { bundles = {} },
        on_attach = function(_, attached_bufnr)
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, {
                    buffer = attached_bufnr,
                    desc = desc,
                    noremap = true,
                    silent = true,
                })
            end

            map("n", "<leader>jo", function() jdtls.organize_imports() end, "[J]ava [O]rganize Imports")
            map("n", "<leader>jev", function() jdtls.extract_variable() end, "[J]ava [E]xtract [V]ariable")
            map("v", "<leader>jev", function() jdtls.extract_variable(true) end, "[J]ava [E]xtract [V]ariable")
            map("n", "<leader>jec", function() jdtls.extract_constant() end, "[J]ava [E]xtract [C]onstant")
            map("v", "<leader>jec", function() jdtls.extract_constant(true) end, "[J]ava [E]xtract [C]onstant")
            map("v", "<leader>jem", function() jdtls.extract_method(true) end, "[J]ava [E]xtract [M]ethod")
            map("n", "<leader>jsi", function() jdtls.super_implementation() end, "[J]ava [S]uper [I]mplementation")
            map("n", "<leader>jts", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.generate.toString" } },
                    apply = true,
                })
            end, "[J]ava Generate [T]o[S]tring")
            map("n", "<leader>jhe", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.generate.hashCodeEquals" } },
                    apply = true,
                })
            end, "[J]ava Generate [H]ashCode/[E]quals")
            map("n", "<leader>ju", function() jdtls.update_project_config() end, "[J]ava [U]pdate Project Config")
        end,
    }

    jdtls.start_or_attach(config, nil, { bufnr = bufnr })
end

return {
    "mfussenegger/nvim-jdtls",
    ft = not is_java_project and { "java" } or nil,
    lazy = is_java_project and false or nil,
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = AUGROUP,
            pattern = "java",
            callback = function(args)
                setup_jdtls(args.buf)
            end,
            desc = "Set up Java LSP (JDTLS)",
        })

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf)
                and vim.api.nvim_buf_is_loaded(buf)
                and vim.bo[buf].filetype == "java" then
                setup_jdtls(buf)
            end
        end
    end,
}
