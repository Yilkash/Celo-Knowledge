export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center pt-20 pb-12 text-center">
      <div className="inline-block mb-4 px-4 py-1.5 rounded-full bg-celo-yellow/20 text-celo-dark font-medium text-sm border border-celo-yellow/50">
        🚀 Powered by the Celo Network
      </div>
      
      <h1 className="text-5xl md:text-7xl font-black tracking-tight text-slate-900 mb-6">
        The Web3 Hub for <br />
        <span className="text-transparent bg-clip-text bg-gradient-to-r from-celo-green to-emerald-400">
          Educational Resources
        </span>
      </h1>
      
      <p className="text-lg md:text-xl text-slate-600 max-w-2xl mx-auto mb-10">
        Share your knowledge, earn native CELO tips, build your reputation, and participate in a decentralized educational economy.
      </p>

      <div className="flex gap-4">
        <button className="bg-celo-green hover:bg-celo-dark text-white px-8 py-4 rounded-xl font-bold text-lg transition-all shadow-lg hover:shadow-celo-green/30 hover:-translate-y-1">
          Explore Registry
        </button>
        <button className="bg-white border-2 border-slate-200 hover:border-celo-green text-slate-700 hover:text-celo-green px-8 py-4 rounded-xl font-bold text-lg transition-all">
          Upload Resource
        </button>
      </div>

      {/* Placeholder Stats Grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-6 w-full mt-24">
        {[
          { label: "Total Resources", value: "0" },
          { label: "CELO Tipped", value: "0.00" },
          { label: "Active Educators", value: "0" },
          { label: "Total Downloads", value: "0" },
        ].map((stat, i) => (
          <div key={i} className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm text-left hover:shadow-md transition-shadow">
            <p className="text-sm font-medium text-slate-500 mb-2">{stat.label}</p>
            <p className="text-3xl font-bold text-slate-900">{stat.value}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
