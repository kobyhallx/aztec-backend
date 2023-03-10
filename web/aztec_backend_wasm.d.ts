/* tslint:disable */
/* eslint-disable */
/**
* @param {any} circuit
* @param {(string)[]} initial_js_witness
* @returns {Uint8Array}
*/
export function compute_witnesses(circuit: any, initial_js_witness: (string)[]): Uint8Array;
/**
* @param {any} acir
* @returns {Uint8Array}
*/
export function serialise_acir_to_barrtenberg_circuit(acir: any): Uint8Array;
/**
* @param {any} acir
* @param {Uint8Array} witness_arr
* @returns {Uint8Array}
*/
export function packed_witness_to_witness(acir: any, witness_arr: Uint8Array): Uint8Array;
/**
* @param {string} vk_method
* @returns {string}
*/
export function eth_contract_from_cs(vk_method: string): string;
/**
* @param {(string)[]} pub_inputs_js_string
* @returns {Uint8Array}
*/
export function serialise_public_inputs(pub_inputs_js_string: (string)[]): Uint8Array;
/**
* A struct representing an aborted instruction execution, with a message
* indicating the cause.
*/
export class WasmerRuntimeError {
  free(): void;
}

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
  readonly memory: WebAssembly.Memory;
  readonly compute_witnesses: (a: number, b: number, c: number, d: number) => void;
  readonly serialise_acir_to_barrtenberg_circuit: (a: number, b: number) => void;
  readonly packed_witness_to_witness: (a: number, b: number, c: number, d: number) => void;
  readonly eth_contract_from_cs: (a: number, b: number, c: number) => void;
  readonly serialise_public_inputs: (a: number, b: number, c: number) => void;
  readonly __wbg_wasmerruntimeerror_free: (a: number) => void;
  readonly __wbindgen_malloc: (a: number) => number;
  readonly __wbindgen_realloc: (a: number, b: number, c: number) => number;
  readonly __wbindgen_export_2: WebAssembly.Table;
  readonly __wbindgen_add_to_stack_pointer: (a: number) => number;
  readonly _dyn_core__ops__function__FnMut___A____Output___R_as_wasm_bindgen__closure__WasmClosure___describe__invoke__h4a8878c31b6c6ea3: (a: number, b: number, c: number, d: number) => void;
  readonly _dyn_core__ops__function__FnMut___A____Output___R_as_wasm_bindgen__closure__WasmClosure___describe__invoke__hff70640a425fdc11: (a: number, b: number, c: number, d: number) => void;
  readonly __wbindgen_free: (a: number, b: number) => void;
  readonly __wbindgen_exn_store: (a: number) => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;
/**
* Instantiates the given `module`, which can either be bytes or
* a precompiled `WebAssembly.Module`.
*
* @param {SyncInitInput} module
*
* @returns {InitOutput}
*/
export function initSync(module: SyncInitInput): InitOutput;

/**
* If `module_or_path` is {RequestInfo} or {URL}, makes a request and
* for everything else, calls `WebAssembly.instantiate` directly.
*
* @param {InitInput | Promise<InitInput>} module_or_path
*
* @returns {Promise<InitOutput>}
*/
export default function init (module_or_path?: InitInput | Promise<InitInput>): Promise<InitOutput>;
